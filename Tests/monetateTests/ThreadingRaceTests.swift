//
//  ThreadingRaceTests.swift
//  monetate-ios-sdkTests
//
//  Failing tests that demonstrate threading races in the SDK.
//
//  Each test reproduces, at the component level, an unsynchronized access
//  pattern that exists in the shipping code (file:line references in the
//  comments). They demonstrate real defects but are wired to keep CI green
//  until the races are fixed:
//
//    ThreadingRaceTests            - the race manifests as an assertion
//                                    failure, recorded via XCTExpectFailure;
//                                    remove the XCTExpectFailure wrapper when
//                                    fixing the race
//    ThreadingRaceSanitizerTests   - pass without ThreadSanitizer; fail when
//                                    the test target is built with TSan
//                                    (enable Thread Sanitizer in the scheme)
//    ScheduleTimerCrashTests       - the race crashes the test process with
//                                    DISPATCH_CLIENT_CRASH (over-resume), so
//                                    it is skipped unless
//                                    MONETATE_RUN_CRASH_TESTS=1 is set; run it
//                                    filtered and in isolation
//

import XCTest
@testable import Monetate

class ThreadingRaceTests: XCTestCase {

    /// Demonstrates the lost-update race in the event queue.
    ///
    /// Personalization writes events with a snapshot -> merge -> replace
    /// sequence (Personalization.swift addEvent/processEvents:
    /// getQueueSnapshot() -> Utility.processEvent(...) -> updateQueue(entire
    /// dictionary)). EventQueueManager makes each step atomic, but not the
    /// sequence: two threads reporting different events concurrently each
    /// snapshot the same state, and whichever updateQueue lands second
    /// silently discards the other thread's event.
    func test_snapshotMergeReplace_losesConcurrentlyReportedEvents() {
        let rounds = 500
        var lostRounds = 0

        for _ in 0..<rounds {
            let manager = EventQueueManager()
            let writers = DispatchGroup()

            let events: [(ContextEnum, MEvent)] = [
                (.PageEvents, PageEvents(pageEvents: ["homepage"])),
                (.Impressions, Impressions(impressionIds: ["imp-1"])!),
            ]

            for (context, event) in events {
                writers.enter()
                DispatchQueue.global().async {
                    // Same pattern as Personalization.addEvent /
                    // processEventsOnEventReporting. Scheduler.immediate keeps
                    // the callback on this thread, which is exactly what the
                    // default Scheduler.main does when the report comes from
                    // the main thread.
                    let snapshot = manager.getQueueSnapshot()
                    Utility.processEvent(context: context, data: event, mqueue: snapshot)
                        .observe(on: Scheduler.immediate)
                        .on(success: { merged in
                            manager.updateQueue(merged) {
                                writers.leave()
                            }
                        })
                }
            }

            XCTAssertEqual(writers.wait(timeout: .now() + 5), .success)
            if manager.getQueueSnapshot().count != events.count {
                lostRounds += 1
            }
        }

        XCTExpectFailure("known race: snapshot->merge->replace is not atomic across threads") {
            XCTAssertEqual(
                lostRounds, 0,
                "concurrently reported events were silently dropped in \(lostRounds)/\(rounds) rounds "
                + "(snapshot->merge->replace is not atomic across threads)")
        }
    }

    /// Demonstrates the main-thread callback hop that breaks getActions
    /// sequencing.
    ///
    /// Future.on without observe(on:) schedules its callback via
    /// Scheduler.main (Future.swift): immediate on the main thread, but
    /// DispatchQueue.main.async from any other thread. Personalization.addEvent
    /// applies its queue update inside such a callback, and getActions then
    /// proceeds on sdkQueue to build the decision request body
    /// (Personalization.swift getActions -> getActionsData ->
    /// buildDecisionRequestBody). Called from a background thread, the body is
    /// built before the deferred queue update runs, so the just-reported event
    /// is missing from the request.
    func test_eventReportedOffMainThread_isMissingFromImmediatelyBuiltRequestBody() {
        let manager = EventQueueManager()
        let done = expectation(description: "background report + body build")
        var body: [[String: Any]] = []

        DispatchQueue.global().async {
            // Personalization.addEvent, verbatim pattern (default scheduler):
            let event = PageEvents(pageEvents: ["checkout"])
            Utility.processEvent(context: .PageEvents, data: event,
                                 mqueue: manager.getQueueSnapshot())
                .on(success: { merged in
                    manager.updateQueue(merged)
                })

            // What getActions does next, immediately, on sdkQueue:
            body = Utility.createEventBody(queue: manager.getQueueSnapshot())
            done.fulfill()
        }

        wait(for: [done], timeout: 5)

        XCTExpectFailure("known race: Scheduler.main defers off-main queue updates") {
            XCTAssertFalse(
                body.isEmpty,
                "event reported immediately before building the request body was not included: "
                + "the queue update was deferred to the main queue by Scheduler.main")
        }
    }
}

/// These two tests exercise real data races that ThreadSanitizer flags
/// deterministically. Build the test target with -sanitize=thread to see them
/// fail; without TSan the cart test can also crash sporadically (Swift Array
/// CoW is not thread-safe).
class ThreadingRaceSanitizerTests: XCTestCase {

    /// The queue "snapshot" is shallow: values are mutable classes.
    /// Utility.processEvent mutates the Cart instance already stored in the
    /// queue (Utility.swift .Cart case: key.cartLines = Cart.merge(...)),
    /// while buildDecisionRequestBody concurrently encodes the same instance
    /// on another thread (Utility.createEventBody -> JSONEncoder). Unsynchronized
    /// write + read of cartLines is a data race.
    func test_cartMergeInPlace_racesWithRequestBodyEncoding() {
        let manager = EventQueueManager()
        let seedLine = CartLine(sku: "sku-0", pid: "pid-0", quantity: 1, currency: "USD", value: "1.00")
        manager.setEvent(Cart(cartLines: [seedLine])!, for: .Cart)

        let group = DispatchGroup()
        let iterations = 2_000

        group.enter()
        DispatchQueue.global().async {
            // Reporter thread: repeatedly merges into the SAME Cart instance.
            for i in 0..<iterations {
                let line = CartLine(sku: "sku-\(i)", pid: "pid-\(i)", quantity: 1, currency: "USD", value: "1.00")
                _ = Utility.processEvent(context: .Cart, data: Cart(cartLines: [line])!,
                                         mqueue: manager.getQueueSnapshot())
            }
            group.leave()
        }

        group.enter()
        DispatchQueue.global().async {
            // Timer/flush thread: repeatedly encodes the queue into a request body.
            for _ in 0..<iterations {
                _ = Utility.createEventBody(queue: manager.getQueueSnapshot())
            }
            group.leave()
        }

        XCTAssertEqual(group.wait(timeout: .now() + 60), .success,
                       "workers did not finish; likely crashed or deadlocked mid-race")
    }

    /// User is mutated without synchronization: setCustomerId writes
    /// user.customerId on the caller's thread (UserID.swift) while
    /// buildDecisionRequestBody reads it from timer/URLSession/sdkQueue
    /// threads (Personalization.swift buildDecisionRequestBody).
    func test_setCustomerId_racesWithRequestBodyRead() {
        let user = User(monetateId: "mid-1")
        let group = DispatchGroup()
        let iterations = 10_000

        group.enter()
        DispatchQueue.global().async {
            for i in 0..<iterations {
                user.setCustomerId(customerId: "customer-\(i)")
            }
            group.leave()
        }

        group.enter()
        DispatchQueue.global().async {
            var reads = 0
            for _ in 0..<iterations {
                if user.customerId != nil { reads += 1 }
            }
            _ = reads
            group.leave()
        }

        XCTAssertEqual(group.wait(timeout: .now() + 60), .success)
    }
}

/// WARNING: this test fails by CRASHING the test process
/// (DISPATCH_CLIENT_CRASH "Over-resume of an object"), which is exactly the
/// production failure mode. It is therefore skipped unless
/// MONETATE_RUN_CRASH_TESTS=1 is set in the test environment; run it filtered
/// and in isolation:
///   MONETATE_RUN_CRASH_TESTS=1 swift test --filter ScheduleTimerCrashTests
class ScheduleTimerCrashTests: XCTestCase {

    override func setUpWithError() throws {
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["MONETATE_RUN_CRASH_TESTS"] == "1",
            "crashes the test runner (dispatch over-resume); set MONETATE_RUN_CRASH_TESTS=1 to run")
    }

    /// ScheduleTimer's state check-then-act around resume()/suspend() is
    /// unsynchronized (ScheduleTimer.swift resume/suspend). In production,
    /// suspend() runs on whatever thread calls callMonetateAPI (flush,
    /// setCustomerId, the timer's own handler) while resume() runs in Future
    /// callbacks on the main thread or URLSession completion threads
    /// (Personalization.swift). Two threads passing `if state == .resumed`
    /// together double-resume the DispatchSourceTimer, which dispatch
    /// terminates with DISPATCH_CLIENT_CRASH.
    func test_concurrentResumeSuspend_overResumesDispatchSource() {
        for _ in 0..<500 {
            let timer = ScheduleTimer(timeInterval: 60, callback: {})
            let start = DispatchSemaphore(value: 0)
            let group = DispatchGroup()

            for worker in 0..<4 {
                group.enter()
                DispatchQueue.global().async {
                    start.wait()
                    if worker % 2 == 0 {
                        timer.resume()
                    } else {
                        timer.suspend()
                    }
                    group.leave()
                }
            }

            for _ in 0..<4 { start.signal() }
            XCTAssertEqual(group.wait(timeout: .now() + 5), .success,
                           "timer workers wedged (suspend-count leak)")

            // Leave the timer resumed so deinit's own (also racy) bookkeeping
            // doesn't mask the resume/suspend race being demonstrated.
            timer.resume()
        }
    }
}


Monetate-personalization-sdk: iOS

Overview:-
This SDK enables easy communication with Engine API and can be used by any application which is built using iOS
Using this SDK we can report events and get actions from Engine API.


Installation:-
 pod 'monetate-ios-sdk'
 pod 'monetate-ios-sdk', :git => 'https://github.com/monetate/monetate-personalization-ios-sdk-cocoapod.git ', :branch => 'main'


Getting started with development :-

Import SDK  
import  "monetate-ios-sdk"

Initialize 
       final var objPersonalization = Personalization(account: Account(instance: "p", domain: "localhost.org", name: "a-701b337c", shortname: "localhost"), user: User(deviceId: "11aa1a1a-111a-111a-11aa-11a1a1111a11"))

Report method:-
Personalization.shared.report(context: .UserAgent, event: UserAgent(key))

This method reports data to Engine API. It take two arguments, first is eventType and second is eventData which is optional. If eventData is not defined, the SDK looks for data in the Context Map which is defined at the time of initialization.


Get Action method

objPersonalization.getActions(context: .UserAgent, requestId: requestId, event: UserAgent(key)).on(success: { (res) in
                self.handleAction(res: res)
            })
This method is used to request decisions and report events as well. It returns object containing the JSON from appropriate actions. eventType and eventData are optional parameters. If we only need actions we can skip optional parameters. requestId is the request identifier tying the response back to an event.

Flush method
        objPersonalization.flush();
For the sake of improving performance, events are queued and all sent at the same time (within a single request) after a 700ms interval is reached. The Flush method forces all enqueued events to be sent to the server immediately and clears the queue.

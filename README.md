
Monetate-personalization-sdk: iOS

Overview:-
This SDK enables easy communication with Engine API and can be used by any application which is built using iOS
Using this SDK we can report events and get actions from Engine API.

<!-- 
## Distribution Steps

1. Execute **build.sh**
2. Update the version information and execute **upload.sh**
3. Obtain the JFrog URL and metadata
4. Update **Package.swift** with the new upload information, then commit and push the changes to the **monetate-personalization-ios-sdk-binary-config** repository.
5. Update the **Podspec** with the new upload information, then publish the updated Podspec to the CocoaPods trunk.
-->
Installation:-

## Swift Package Manager (SPM)

The Monetate Personalization SDK can be integrated using Swift Package Manager.

Using Xcode:

1. Open your project in Xcode
2. Select File → Add Packages
3. Enter the repository URL:
   https://github.com/monetate/monetate-personalization-ios-sdk-cocoapod.git
4. Choose latest release version or 'main' branch for recent updates
5. Add the package to your target

Using Package.swift:

Add the following dependency to your Package.swift file.

        dependencies: [
            .package(
                url: "https://github.com/monetate/monetate-personalization-ios-sdk-cocoapod",
                branch: "main"
            )
        ]


## CocoaPods
   
pod 'monetate-ios-sdk'


Getting started with development :-

  
    import  "monetate-ios-sdk"

Initialize 

       final var objPersonalization = Personalization(account: Account(instance: "p", domain: "localhost.org", name: "a-701b337c", shortname: "localhost"), 
                                                            user: User(deviceId: "11aa1a1a-111a-111a-11aa-11a1a1111a11"))

Report method:-

        // ContextObj based Approach
        let contextObj = ContextObj()
        try? contextObj.addPageDetails(pageType: "samplePage", path: nil, url: "sampleURL", categories: nil, breadcrumbs: nil)
        personalization.reportPageDetails(contextData: contextObj)

This method reports data to Engine API. It takes ContextObject instance, with associated event data. 


Get Action method

        do {
            try contextObj.addPurchaseData(purchaseId: "321", purchaseLineData: [PurchaseLine(sku: "sku1", pid: "pid1", quantity: 2, currency: "USD", value: "8")])
            try contextObj.addPurchaseData(purchaseId: "654", purchaseLineData: [PurchaseLine(sku: "sku2", pid: "pid2", quantity: 2, currency: "AED", value: "12")])
        }
        
        catch {
            print(error.localizedDescription)
        }
        

        personalization.getActions(context: contextObj, arrActionTypes: ["monetate:action:OmnichannelJson"], includeReporting: false).on(success: { data in
            print(String(describing: data))

        }, failure:{ err in
            print(err.localizedDescription)
        })
            
This method is used to request decisions and report events as well. It returns object containing the JSON from appropriate actions. Includereporting accepts the boolean value true or false , true insists that response will have the impression reporting data, and false value insists that it will not have impression Reporting data in response. 

Flush method

        objPersonalization.flush();
        
For the sake of improving performance, events are queued and all sent at the same time (within a single request) after a 700ms interval is reached. The Flush method forces all enqueued events to be sent to the server immediately and clears the queue.

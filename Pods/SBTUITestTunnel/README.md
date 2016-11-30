# SBTUITestTunnel

[![Version](https://img.shields.io/cocoapods/v/SBTUITestTunnel.svg?style=flat)](http://cocoadocs.org/docsets/SBTUITestTunnel)
[![License](https://img.shields.io/cocoapods/l/SBTUITestTunnel.svg?style=flat)](http://cocoadocs.org/docsets/SBTUITestTunnel)
[![Platform](https://img.shields.io/cocoapods/p/SBTUITestTunnel.svg?style=flat)](http://cocoadocs.org/docsets/SBTUITestTunnel)

## Overview

Apple introduced a new UI Testing feature starting from Xcode 7 that is, quoting Will Turner [on stage at the WWDC](https://developer.apple.com/videos/play/wwdc2015/406/), a huge expansion of the testing technology in the developer tools. The framework is easy to use and the integration with the IDE is great however there is a major problem with the way tests are launched. Testing code runs as a separate process which prevents to directly share data with the app under test making it hard to do things like dynamically inject data or stub network calls.

With SBTUITestTunnel we extended UI testing functionality allowing to dynamically:
* stub network calls
* interact with NSUserDefaults and Keychain
* download/upload files from/to the app's sandbox
* monitor network calls
* define custom blocks of codes executed in the application target

The library consists of two separated components which communicate with each other, one to be instantiate in the application and the other in the testing code. A web server inside the application is used to create the link between the two components allowing test code to send requests to the application.

## Requirements

Requires iOS 8.0 or higher.

## Installation (CocoaPods)

We strongly suggest to use [cocoapods](https://cocoapods.org) being the easiest way to embed the library inside your project.

Your Podfile should include the sub project `SBTUITestTunnel/Server` for the app target and `SBTUITestTunnel/Client` for the UI test target.

    target 'APP_TARGET' do
      pod 'SBTUITestTunnel/Server'
    end
    target 'UITESTS_TARGET' do
      pod 'SBTUITestTunnel/Client'
    end

**🔥 If you’re using CocoaPods v1.0 and your UI Tests fail to start, you may need to add $(FRAMEWORK_SEARCH_PATHS) to your Runpath Search Paths in the Build Settings of the UI Test target!**

## Installation (Manual)

Add files in the *Server* and *Common* folder to your application's target, *Client* and *Common* to the UI test target.

## Setup

### Application target

On the application's target call SBTUITestTunnelServer's `takeOff` method inside the application's delegate `initialize` class method.

**Objective-C**

    #import "SBTAppDelegate.h"
    #import "SBTUITestTunnelServer.h"

    @implementation SBTAppDelegate

    + (void)initialize {
        [super initialize];
        [SBTUITestTunnelServer takeOff];
    }

    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        return YES;
    }

    @end

**Swift**

    import UIKit
    import SBTUITestTunnel

    @UIApplicationMain
    class AppDelegate: UIResponder, UIApplicationDelegate {
        var window: UIWindow?

        override class func initialize() {
            SBTUITestTunnelServer.takeOff()
            super.initialize()
        }

        func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
            return true
        }
    }

**Note** Each and every file of the framework is wrapped around #if DEBUG pre-processor directive to avoid that any of its code accidentally ends in production when releasing. Check your pre-processor macros verifying that DEBUG is not defined in your release code!

### UI Testing target

Instead of using `XCUIApplication` use `SBTUITunneledApplication`.


## Usage

`SBTUITunneledApplication`'s headers are well commented making the library's functionality self explanatory. You can also checkout the UI test target in the example project which show basic usage of the library.


### Startup

At launch you can optionally provide some options and a startup block which will be executed before the `applicationDidFinishLaunching` will be called. This is the right place to prepare (inject files, modify NSUserDefaults, etc) the app's startup status.

#### Launch with no options

**Objective-C**

    SBTUITunneledApplication *app = [[SBTUITunneledApplication alloc] init];
    [app launch];

**Swift**

    let app = SBTUITunneledApplication()
    app.launch()


#### Launch with options and startupBlock

**Objective-C**

    SBTUITunneledApplication *app = [[SBTUITunneledApplication alloc] init];

    [app launchTunnelWithOptions:@[SBTUITunneledApplicationLaunchOptionResetFilesystem]
                    startupBlock:^{
        [app setUserInterfaceAnimationsEnabled:NO];
        [app userDefaultsSetObject:@(YES) forKey:@"show_startup_warning"]
        ...
    }];

**Swift**

    app = SBTUITunneledApplication()
    app.launchTunnelWithOptions([SBTUITunneledApplicationLaunchOptionResetFilesystem]) {
        // do additional setup before the app launches
        // i.e. prepare stub request, start monitoring requests
    }

- `SBTUITunneledApplicationLaunchOptionResetFilesystem` will delete the entire app's sandbox filesystem
- `SBTUITunneledApplicationLaunchOptionDisableUITextFieldAutocomplete` disables UITextField's autocomplete functionality which can lead to unexpected results when typing text.

### SBTRequestMatch

The stubbing/monitoring/throttling methods of the library require a `SBTRequestMatch` object in order to determine whether they should react to a network request.

You can specify url, query (parameter in GET and DELETE, body in POST and PUT) and HTTP method using one of the several class methods available

**Objective-C**

    + (nonnull instancetype)URL:(nonnull NSString *)url; // any request matching the specified regex on the request URL
    + (nonnull instancetype)URL:(nonnull NSString *)url query:(nonnull NSString *)query; // same as above additionally matching the query (params in GET and DELETE, body in POST and PUT)
    + (nonnull instancetype)URL:(nonnull NSString *)url query:(nonnull NSString *)query method:(nonnull NSString *)method; // same as above additionally matching the HTTP method
    + (nonnull instancetype)URL:(nonnull NSString *)url method:(nonnull NSString *)method; // any request matching the specified regex on the request URL and HTTP method

    + (nonnull instancetype)query:(nonnull NSString *)query; // any request matching the specified regex on the query (params in GET and DELETE, body in POST and PUT)
    + (nonnull instancetype)query:(nullable NSString *)query method:(nonnull NSString *)method; // same as above additionally matching the HTTP method

    + (nonnull instancetype)method:(nonnull NSString *)method; // any request matching the HTTP method

**Swift**

    public class func URL(url: String) -> Self // any request matching the specified regex on the request URL
    public class func URL(url: String, query: String) -> Self // same as above additionally matching the query (params in GET and DELETE, body in POST and PUT)
    public class func URL(url: String, query: String, method: String) -> Self // same as above additionally matching the HTTP method
    public class func URL(url: String, method: String) -> Self // any request matching the specified regex on the request URL and HTTP method

    public class func query(query: String) -> Self // any request matching the specified regex on the query (params in GET and DELETE, body in POST and PUT)
    public class func query(query: String?, method: String) -> Self // same as above additionally matching the HTTP method

    public class func method(method: String) -> Self // any request matching the HTTP method


### Stubbing

To stub a network request you pass the appropriate `SBTRequestMatch` object

**Objective-C**

    NSString *stubId = [app stubRequestsMatching:[SBTRequestMatch URL:@"google.com"]
                             returnJsonDictionary:@{@"request": @"stubbed"}
                                       returnCode:200
                                     responseTime:SBTUITunnelStubsDownloadSpeed3G];
    // from here on network request containing 'apple' will return a JSON {"request" : "stubbed" }
    ...

    [app stubRequestsRemoveWithId:stubId]; // To remove the stub either use the identifier

    [app stubRequestsRemoveAll]; // or remove all active stubs

**Swift**

    let stubId = app.stubRequestsMatching:SBTRequestMatch(SBTRequestMatch.URL("google.com"), returnJsonDictionary: ["key": "value"], returnCode: 200, responseTime: SBTUITunnelStubsDownloadSpeed3G)

    // from here on network request containing 'apple' will return a JSON {"request" : "stubbed" }
    ...

    app.stubRequestsRemoveWithId(stubId) // To remove the stub either use the identifier

    app.stubRequestsRemoveAll() // or remove all active stubs


### NSUserDefaults

#### Set object

**Objective-C**

    [app userDefaultsSetObject:@"test_value" forKey:@"test_key"]);

**Swift**

    app.userDefaultsSetObject("test_value", forKey: "test_key");

#### Get object

**Objective-C**

    id obj = [app userDefaultsObjectForKey:@"test_key"]

**Swift**

    let obj = app.userDefaultsObjectForKey("test_key")

#### Remove object

**Objective-C**

    [app userDefaultsRemoveObjectForKey:@"test_key"]

**Swift**

    app.userDefaultsRemoveObjectForKey("test_key")


### Upload / Download items

#### Upload

**Objective-C**

    NSString *testFilePath = ... // path to file
    [app uploadItemAtPath:testFilePath toPath:@"test_file.txt" relativeTo:NSDocumentDirectory];

**Swift**

    let pathToFile = ... // path to file
    app.uploadItemAtPath(pathToFile, toPath: "test_file.txt", relativeTo: .DocumentDirectory)

#### Download

**Objective-C**

    NSData *uploadData = [app downloadItemFromPath:@"test_file.txt" relativeTo:NSDocumentDirectory];

**Swift**

    let uploadData = app.downloadItemFromPath("test_file.txt", relativeTo: .DocumentDirectory)

### Network monitoring

This may come handy when you need to check that specific network requests are made. You pass an `SBTRequestMatch` like for stubbing methods.

**Objective-C**

    [app monitorRequestsMatching:[SBTRequestMatch URL:@"apple.com"]];

    // Interact with UI. Once ready flush calls and get the list of requests

    NSArray<SBTMonitoredNetworkRequest *> *requests = [app monitoredRequestsFlushAll];

    for (SBTMonitoredNetworkRequest *request in requests) {
        NSData *requestBody = request.request.HTTPBody; // HTTP Body in POST request?
        NSDictionary *responseJSON = request.responseJSON;
        NSTimeInterval requestTime = request.requestTime; // How long did the request take?
    }

    [app monitorRequestRemoveAll];

**Swift**

    app.monitorRequestsMatching(SBTRequestMatch.URL("apple.com"))

    // Interact with UI. Once ready flush calls and get the list of requests

    let requests: [SBTMonitoredNetworkRequest] = app.monitoredRequestsFlushAll()

    for request in requests {
        let requestBody = request.request!.HTTPBody // HTTP Body in POST request?
        let responseJSON = request.responseJSON
        let requestTime = request.requestTime // How long did the request take?
    }

    app.monitorRequestRemoveAll()

### Throttling

The library allows to throttle network calls by specifying a response time, which can be a positive number of seconds or one of the predefined `SBTUITunnelStubsDownloadSpeed*`constants. You pass an `SBTRequestMatch` like for stubbing methods.

**Objective-C**

    NSString *throttleId = [app throttleRequestsMatching:[SBTRequestMatch URL:@"apple.com"] responseTime:SBTUITunnelStubsDownloadSpeed3G];

    [app throttleRequestRemoveWithId:throttleId];

**Swift**

    let throttleId = app.throttleRequestsMatching(SBTRequestMatch.URL("apple.com"), responseTime:SBTUITunnelStubsDownloadSpeed3G) ?? ""

    app.throttleRequestRemoveWithId(throttleId)

### Custom defined blocks of code

You can easily add a custom block of code in the application target that can be conveniently invoked from the test target. An NSString identifies the block of code when registering and invoking it.

#### Application target

You register a block of code that will be invoked from the test target as follows:

**Objective-C**

    [SBTUITestTunnelServer registerCustomCommandNamed:@"myCustomCommand" block:^NSObject *(NSObject *object) {
        // the block of code that will be executed when the test target calls
        // [SBTUITunneledApplication performCustomCommandNamed:object:];

        return @"Any object you want to pass back to test target";
    }];

**Swift**

    SBTUITestTunnelServer.registerCustomCommandNamed("myCustomCommandKey") {
        injectedObject in
        // this block will be invoked from app.performCustomCommandNamed()

        return "Any object you want to pass back to test target"
    }

**Note** It is your responsibility to unregister the custom command when it is no longer needed. Failing to do so may end up with unexpected behaviours.

#### Test target

You invoke the custom command by using the same identifier used on registration, optionally passing an NSObject:

**Objective-C**

    NSObject *objReturnedByBlock = [app performCustomCommandNamed:@"myCustomCommand" object:someObject];

**Swift**

    let objReturnedByBlock = app.performCustomCommandNamed("myCustomCommand", object: someObjectToInject)

## Thanks

Kudos to the developers of the following pods which we use in SBTUITestTunnel:

* [GCDWebServer](https://github.com/swisspol/GCDWebServer)
* [FXKeychain](https://github.com/nicklockwood/FXKeychain)

## Contributions

Contributions are welcome! If you have a bug to report, feel free to help out by opening a new issue or sending a pull request.

## Authors

[Tomas Camin](https://github.com/tcamin) ([@tomascamin](https://twitter.com/tomascamin))

## License

SBTUITestTunnel is available under the Apache License, Version 2.0. See the LICENSE file for more info.

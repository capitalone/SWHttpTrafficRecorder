# SWHttpTrafficRecorder [![Build Status](https://travis-ci.org/capitalone/SWHttpTrafficRecorder.svg?branch=master)](https://travis-ci.org/capitalone/SWHttpTrafficRecorder)

**SWHttpTrafficRecorder** provides an easy way to record all the HTTP(s) traffic in the device’s file system while the user is using your app at the same time. It can be used for different purposes, like testing, replaying the workflow or logging an app's network activity for debugging purposes.  See [OHHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs), [Nocilla](https://github.com/luisobo/Nocilla) or [Mocktail](https://github.com/puls/objc-mocktail) for examples of how the recorded files can be used (this library is inspired while using the above frameworks). This library has been developed solely for testing purposes. We highly recommend against using it in production environment. However, if you choose to include it anyway, there are security considerations that must be taken into account. 

**Note**: if you like this library, please feel free to fork or star it using the buttons on the top of this page. 

### Setup

#### Integrating in Your Project

##### [CocoaPods](http://cocoapods.org)
The recommended way to add **SWHttpTrafficRecorder** to your project. Add `SWHttpTrafficRecorder` to your `Podfile`:

```ruby
pod 'SWHttpTrafficRecorder'
```

##### [Carthage](https://github.com/Carthage/Carthage)

Add this repo to your `Cartfile`:

```ruby
github "capitalone/SWHttpTrafficRecorder"
```

##### Manual
Or since the library contains only two files (`SWHttpTrafficRecorder.h` and `SWHttpTrafficRecorder.m`), you can just drop them anywhere in your project and it is done. 

#### Getting Started

Even though the library is highly customizable, you can get started just by inserting one line of code.  

###### Objective C: 

```objc
[[SWHttpTrafficRecorder sharedRecorder] startRecording];
```    

###### Swift: 

```swift
SWHttpTrafficRecorder.sharedRecorder().startRecording()
```

**Note**: `NSURLConnection` and `NSURLSession` is supported, including [AFNetworking](https://github.com/AFNetworking/AFNetworking), or any networking framework that use Cocoa's URL Loading System.   
To use with `NSURLSession` based requests, you need to provide the `NSURLSessionConfiguration` to record, see the method `- (BOOL)startRecordingAtPath:(NSString *)recordingPath forSessionConfiguration:(NSURLSessionConfiguration *)sessionConfig error:(NSError **) error`. 

### Features

The library can be used to record the HTTP(s) traffic in 3 commonly used formats: Mocktail, response body only and HTTP(s) Raw Message (the format output by `curl -is`). In addition, it can be used to monitor the HTTP(s) traffic activity between the client and web service through a progress update delegate. Overall, the library is highly customizable, including the following configurable parameters: 

* **recordingFormat**: The recording format the recorder is going to use. It can be Mocktail,  response body only or HTTP(s) Raw Message. 
* **fileNamingBlock**: The recorded file name. A file is recorded per each HTTP(s) request and its file name can be customized. By default, it uses a combination of the request's last path component, a time stamp and a number.
* **recordingTestBlock**: Whether to record or skip a HTTP(s) request.
* **progressDelegate**: An delegate when provided which would receive updates of recording process, including when the HTTP(s) requests are received, loaded and recorded. 
* **base64TestBlock**: Whether to base64 encode a response body. Only applicable to Mocktail format. By default, only images are base64 encoded.
* **urlRegexPatternBlock**: URL matching regular expression. Only applicable to Mocktail format. The default is to use the path and replace query parameter values as `.*`.
* **replacementDict**: A dictionarity containing the information over what data to be replaced by corresponding tokens. Only applicable to Mocktail format. If no value is provided, no replacement would be done. 
* **createFileInCustomFormatBlock**: Using this parameter to customize the recording in any format that you can implement.

### Requirements

The library is tested and working in iOS 7 and above. Older version may work but it is not explicitly tested. It only requires Foundation.framework that is probably included in any iOS project. 

You may need the latest developer tools in order to build the demo project and run the tests. 


### Security Consideration

While creating files for HTTP(s) requests, the recorder uses `NSFileProtectionComplete` for `NSFileProtectionKey` attribute to improve the file security. It is a generic library that is designed to record and monitor traffic activity, however, each app may apply its own discretion over what to record and monitor based on its own policy and regulation.


### Roadmap

The project is in its early stage. We are intending to apply it to different projects both internally and externally, and fix any issues that are found. In addition, we are going to continue to improve it as the following:

1. Create a testing suite for regression to make sure future contributions do not break existing functionalities; 
2. Provide more documentation and sample code through wiki page.

If you want to help with any of the above or have any other ideas over how to enhance it or fix a bug, pull requests/new issues/comments/questions are highly welcome.

### Contributions

We welcome your interest in Capital One’s Open Source Projects. Any contributor to this project must accept and sign a Capital One Contributor Licensing Agreement (CLA). Except for the license granted in this agreement to Capital One and to recipients of software distributed by Capital One, you reserve all right, title, and interest in and to your contributions; this agreement does not impact your rights to use your own contributions for any other purpose.

[Link to CLA](https://docs.google.com/forms/d/19LpBBjykHPox18vrZvBbZUcK6gQTj7qv1O5hCduAZFU/viewform)


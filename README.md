SWHttpTrafficRecorder provides an easy way to record all the HTTP traffic while the user is using your app at the same time. It can be used for different purposes, including recording the files and use them for mocking later on or logging an app's network activity for debugging purpose. 

###### Installing In Your Projects

The library contains only two files (SWHttpTrafficRecorder.h and SWHttpTrafficRecorder.m). So you can just drop them anywhere in your project and it is done. Will provide a CocoaPods spec later on.

###### Usage Example

Even though the tool is highly customizable, to start using the tool can not be simpler. It needs only one line of code: 

######## Objective C: 

```
[[SWHttpTrafficRecorder sharedRecorder] startRecordingAtPath:nil error:nil];
```    

######## Swift: 

```
SWHttpTrafficRecorder.sharedRecorder().startRecordingAtPath(nil, error: nil)
```

###### Customizable Features:

* The recorded folder: default to caches system directory. Can be anywhere the folder is writable. 
* Recording format: It has built-in support for two formats: Mocktail and response body only.  Can be customized to output in any format that you can implement. 
* Whether to record or skip a HTTP request. 
* Whether to base64 encode a request. By default, only images are base64 encoded. 
* The recorded file name. A file is recorded per each HTTP request and its file name can be customized. By default, it uses the last path component and time stamp. 
* URL matching regular expression. This is only applicable to Mocktail format. The default is to use the path, and replace query parameter values as .*. 
   
    


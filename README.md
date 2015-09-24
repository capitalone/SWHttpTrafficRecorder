SWHttpTrafficRecorder provides an easy way to record all the HTTP traffic while the user is using your app at the same time. It can be used for different purposes, including recording the files to use them for mocking later on (see https://github.com/AliSoftware/OHHTTPStubs or https://github.com/puls/objc-mocktail for examples of how the recorded files can be used) or logging an app's network activity for debugging purpose. 

### Installing In Your Projects

The library contains only two files (SWHttpTrafficRecorder.h and SWHttpTrafficRecorder.m). So you can just drop them anywhere in your project and it is done. Will provide a CocoaPods spec later on.

### Usage Example

Even though the tool is highly customizable, to start using the tool can not be simpler. It needs only one line of code: 

###### Objective C: 

```
[[SWHttpTrafficRecorder sharedRecorder] startRecording];
```    

###### Swift: 

```
SWHttpTrafficRecorder.sharedRecorder().startRecording()
```

### Customizable Features:

* The recorded folder: default to caches system directory. Can be anywhere the folder is writable. 
* Recording format: It has built-in support for 3 formats: Mocktail,  response body only and HTTP Raw Message(the format output by `curl -is`).  Can be customized to output in any format that you can implement. 
* Whether to record or skip a HTTP request. 
* Whether to base64 encode a response body. By default, only images are base64 encoded. 
* The recorded file name. A file is recorded per each HTTP request and its file name can be customized. By default, it uses combination of the request's last path component and current time stamp. 
* URL matching regular expression. This is only applicable to Mocktail format. The default is to use the path, and replace query parameter values as .*. 
   
    
### TO-DO list

If you can help with any of the following tasks, your effort would be highly appreciated: just make the change and submit a pull request.  

* Check whether the path is writable at start recording.
* Implement isNotValidFileName: Could some last path component contains invalid character?
* Need to figure out whether it is possible to record an error in Mocktail format and if yes, how to do that. 
* Any other error handlings
* Customizable header block?
* Documentation - README, and comments in header, in particular the customizable properites


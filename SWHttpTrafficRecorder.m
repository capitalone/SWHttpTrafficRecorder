/***********************************************************************************
 * Copyright 2015 CapitalOne
 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 
 * http://www.apache.org/licenses/LICENSE-2.0
 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 ***********************************************************************************/


////////////////////////////////////////////////////////////////////////////////

//  Created by Jinlian (Sunny) Wang on 8/23/15.

#import "SWHttpTrafficRecorder.h"

NSString * const SWHTTPTrafficRecordingProgressRequestKey   = @"REQUEST_KEY";
NSString * const SWHTTPTrafficRecordingProgressResponseKey  = @"RESPONSE_KEY";
NSString * const SWHTTPTrafficRecordingProgressBodyDataKey  = @"BODY_DATA_KEY";
NSString * const SWHTTPTrafficRecordingProgressFilePathKey  = @"FILE_PATH_KEY";
NSString * const SWHTTPTrafficRecordingProgressFileFormatKey= @"FILE_FORMAT_KEY";
NSString * const SWHTTPTrafficRecordingProgressErrorKey     = @"ERROR_KEY";

@interface SWRecordingProtocol : NSURLProtocol @end

@interface SWHttpTrafficRecorder()
@property(nonatomic, assign, readwrite) BOOL isRecording;
@property(nonatomic, strong) NSString *recordingPath;
@end

@implementation SWHttpTrafficRecorder

+ (instancetype)sharedRecorder
{
    static SWHttpTrafficRecorder *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = self.new;
        shared.isRecording = NO;
        shared.recordingFormat = SWHTTPTrafficRecordingFormatMocktail;
    });
    return shared;
}

- (void)startRecording{
    [self startRecordingAtPath:nil error:nil];
}

- (void)startRecordingAtPath:(NSString *)path error:(NSError **)error{
    if(!self.isRecording){
        if(path){
            self.recordingPath = path;
        } else {
            self.recordingPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        }
        
        [NSURLProtocol registerClass:[SWRecordingProtocol class]];
    }
    self.isRecording = YES;
}


- (void)stopRecording{
    if(self.isRecording){
        [NSURLProtocol unregisterClass:[SWRecordingProtocol class]];
    }
    self.isRecording = NO;
}

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Protocol Class


static NSString * const SWRecordingLProtocolHandledKey = @"SWRecordingLProtocolHandledKey";

@interface SWRecordingProtocol () <NSURLConnectionDelegate>

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *mutableData;
@property (nonatomic, strong) NSURLResponse *response;

@end


@implementation SWRecordingProtocol

#pragma mark - NSURLProtocol overrides

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    BOOL isHTTP = [request.URL.scheme isEqualToString:@"https"] || [request.URL.scheme isEqualToString:@"http"];
    if ([NSURLProtocol propertyForKey:SWRecordingLProtocolHandledKey inRequest:request] || !isHTTP) {
        return NO;
    }
    
    [self updateRecorderProgressDelegate:SWHTTPTrafficRecordingProgressReceived userInfo:@{SWHTTPTrafficRecordingProgressRequestKey: request}];
    
    BOOL(^testBlock)(NSURLRequest *request) = [SWHttpTrafficRecorder sharedRecorder].recordingTestBlock;
    BOOL canInit = YES;
    if(testBlock){
        canInit = testBlock(request);
    }
    if(!canInit){
        [self updateRecorderProgressDelegate:SWHTTPTrafficRecordingProgressSkipped userInfo:@{SWHTTPTrafficRecordingProgressRequestKey: request}];
    }
    return canInit;
}

+ (NSURLRequest *) canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void) startLoading {
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:SWRecordingLProtocolHandledKey inRequest:newRequest];
    
    [self.class updateRecorderProgressDelegate:SWHTTPTrafficRecordingProgressStarted userInfo:@{SWHTTPTrafficRecordingProgressRequestKey: self.request}];
    
    self.connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
}

- (void) stopLoading {
    
    [self.connection cancel];
    self.mutableData = nil;
}

#pragma mark - NSURLConnectionDelegate

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    
    self.response = response;
    self.mutableData = [[NSMutableData alloc] init];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
    
    [self.mutableData appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
    
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)self.response;
    NSURLRequest *request = (NSURLRequest*)connection.currentRequest;
    
    [self.class updateRecorderProgressDelegate:SWHTTPTrafficRecordingProgressLoaded
                                      userInfo:@{SWHTTPTrafficRecordingProgressRequestKey: self.request,
                                                 SWHTTPTrafficRecordingProgressResponseKey: self.response,
                                                 SWHTTPTrafficRecordingProgressBodyDataKey: self.mutableData
                                                 }];
    
    NSString *path = [self getFilePath:request response:response];
    SWHTTPTrafficRecordingFormat format = [SWHttpTrafficRecorder sharedRecorder].recordingFormat;
    if(format == SWHTTPTrafficRecordingFormatBodyOnly){
        [self createBodyOnlyFileWithRequest:request response:response data:self.mutableData atFilePath:path];
    } else if(format == SWHTTPTrafficRecordingFormatMocktail){
        [self createMocktailFileWithRequest:request response:response data:self.mutableData atFilePath:path];
    } else if(format == SWHTTPTrafficRecordingFormatHTTPMessage){
        [self createHTTPMessageFileWithRequest:request response:response data:self.mutableData atFilePath:path];
    } else if(format == SWHTTPTrafficRecordingFormatCustom && [SWHttpTrafficRecorder sharedRecorder].createFileInCustomFormatBlock != nil){
        [SWHttpTrafficRecorder sharedRecorder].createFileInCustomFormatBlock(request, response, self.mutableData, path);
    } else {
        NSLog(@"File format: %ld is not supported.", (long)format);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
    
    [self.class updateRecorderProgressDelegate:SWHTTPTrafficRecordingProgressFailedToLoad
                                      userInfo:@{SWHTTPTrafficRecordingProgressRequestKey: self.request,
                                                 SWHTTPTrafficRecordingProgressErrorKey: error
                                                 }];
}

#pragma mark - File Creation Utility Methods

-(NSString *)getFileName:(NSURLRequest *)request{
    NSString *fileName = [request.URL lastPathComponent];
    
    if(!fileName || [self isNotValidFileName: fileName]){
        fileName = @"Mocktail";
    }
    
    fileName = [NSString stringWithFormat:@"%@_%d", fileName, (int)[NSDate timeIntervalSinceReferenceDate]];
    
    NSString *(^fileNamingBlock)(NSURLRequest *request, NSString *defaultName) = [SWHttpTrafficRecorder sharedRecorder].fileNamingBlock;
    
    if(fileNamingBlock){
        fileName = fileNamingBlock(request, fileName);
    }
    return fileName;
}

-(BOOL)isNotValidFileName:(NSString*) fileName{
    return NO;
}

-(NSString *)getFilePath:(NSURLRequest *)request response:(NSHTTPURLResponse *)response{
    NSString *recordingPath = [SWHttpTrafficRecorder sharedRecorder].recordingPath;
    NSString *filePath = [[recordingPath stringByAppendingPathComponent:[self getFileName:request]] stringByAppendingPathExtension:[self getFileExtension:request response:response]];

    return filePath;
}

-(NSString *)getFileExtension:(NSURLRequest *)request response:(NSHTTPURLResponse *)response{
    SWHTTPTrafficRecordingFormat format = [SWHttpTrafficRecorder sharedRecorder].recordingFormat;
    if(format == SWHTTPTrafficRecordingFormatBodyOnly && [response.MIMEType isEqualToString:@"application/json"]){
        return @"json";
    } else if(format == SWHTTPTrafficRecordingFormatMocktail){
        return @"tail";
    } else if(format == SWHTTPTrafficRecordingFormatHTTPMessage){
        return @"response";
    }
    
    return @"txt";
}

-(BOOL)toBase64Body:(NSURLRequest *)request andResponse:(NSHTTPURLResponse *)response{
    if([SWHttpTrafficRecorder sharedRecorder].base64TestBlock){
        return [SWHttpTrafficRecorder sharedRecorder].base64TestBlock(request, response);
    }
    return [response.MIMEType hasPrefix:@"image"];
}

-(NSData *)doBase64:(NSData *)bodyData request: (NSURLRequest*)request response:(NSHTTPURLResponse*)response{
    BOOL toBase64 = [self toBase64Body:request andResponse:response];
    if(toBase64 && bodyData){
        return [bodyData base64EncodedDataWithOptions:0];
    } else {
        return bodyData;
    }
}

-(NSData *)doJSONPrettyPrint:(NSData *)bodyData request: (NSURLRequest*)request response:(NSHTTPURLResponse*)response{
    if([response.MIMEType isEqualToString:@"application/json"] && bodyData)
    {
        NSError *error;
        id json = [NSJSONSerialization JSONObjectWithData:bodyData options:0 error:&error];
        if(json && !error){
            bodyData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&error];
            if(error){
                NSLog(@"Somehow the content is not a json though the mime type is json: %@", error);
            }
        } else {
            NSLog(@"Somehow the content is not a json though the mime type is json: %@", error);
        }
    }
    return bodyData;
}

#pragma mark - BodyOnly File Creation

-(void)createBodyOnlyFileWithRequest:(NSURLRequest*)request response:(NSHTTPURLResponse*)response data:(NSData*)data atFilePath:(NSString *)filePath
{
    data = [self doBase64:data request:request response:response];
    
    data = [self doJSONPrettyPrint:data request:request response:response];
    
    BOOL created = [NSFileManager.defaultManager createFileAtPath:filePath contents:data attributes:nil];
    [self.class updateRecorderProgressDelegate:created ? SWHTTPTrafficRecordingProgressRecorded : SWHTTPTrafficRecordingProgressFailedToRecord
                                      userInfo:@{SWHTTPTrafficRecordingProgressRequestKey: self.request,
                                                 SWHTTPTrafficRecordingProgressResponseKey: self.response,
                                                 SWHTTPTrafficRecordingProgressBodyDataKey: self.mutableData,
                                                 SWHTTPTrafficRecordingProgressFileFormatKey: @(SWHTTPTrafficRecordingFormatBodyOnly),
                                                 SWHTTPTrafficRecordingProgressFilePathKey: filePath
                                                 }];
}

#pragma mark - Mocktail File Creation

-(void)createMocktailFileWithRequest:(NSURLRequest*)request response:(NSHTTPURLResponse*)response data:(NSData*)data atFilePath:(NSString *)filePath
{
    NSMutableString *tail = NSMutableString.new;
    [tail appendFormat:@"%@\n", request.HTTPMethod];
    [tail appendFormat:@"%@\n", [self getURLRegexPattern:request]];
    [tail appendFormat:@"%ld\n", (long)response.statusCode];
    [tail appendFormat:@"%@%@\n\n", response.MIMEType, [self toBase64Body:request andResponse:response] ? @";base64": @""];
    
    data = [self doBase64:data request:request response:response];
    
    data = [self doJSONPrettyPrint:data request:request response:response];
    
    [tail appendFormat:@"%@", data ? [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] : @""];
    
    BOOL created = [NSFileManager.defaultManager createFileAtPath:filePath contents:[tail dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    [self.class updateRecorderProgressDelegate:created ? SWHTTPTrafficRecordingProgressRecorded : SWHTTPTrafficRecordingProgressFailedToRecord
                                      userInfo:@{SWHTTPTrafficRecordingProgressRequestKey: self.request,
                                                 SWHTTPTrafficRecordingProgressResponseKey: self.response,
                                                 SWHTTPTrafficRecordingProgressBodyDataKey: self.mutableData,
                                                 SWHTTPTrafficRecordingProgressFileFormatKey: @(SWHTTPTrafficRecordingFormatMocktail),
                                                 SWHTTPTrafficRecordingProgressFilePathKey: filePath
                                                 }];
}

-(NSString *)getURLRegexPattern:(NSURLRequest *)request{
    NSString *urlPattern = request.URL.path;
    if(request.URL.query){
        NSArray *queryArray = [request.URL.query componentsSeparatedByString:@"&"];
        NSMutableArray *processedQueryArray = [[NSMutableArray alloc] initWithCapacity:queryArray.count];
        [queryArray enumerateObjectsUsingBlock:^(NSString *part, NSUInteger idx, BOOL *stop) {
            NSRegularExpression *urlRegex = [NSRegularExpression regularExpressionWithPattern:@"(.*)=(.*)" options:NSRegularExpressionCaseInsensitive error:nil];
            part = [urlRegex stringByReplacingMatchesInString:part options:0 range:NSMakeRange(0, part.length) withTemplate:@"$1=.*"];
            [processedQueryArray addObject:part];
        }];
        urlPattern = [NSString stringWithFormat:@"%@\\?%@", request.URL.path, [processedQueryArray componentsJoinedByString:@"&"]];
    }
    
    NSString *(^urlRegexPatternBlock)(NSURLRequest *request, NSString *defaultPattern) = [SWHttpTrafficRecorder sharedRecorder].urlRegexPatternBlock;
    
    if(urlRegexPatternBlock){
        urlPattern = urlRegexPatternBlock(request, urlPattern);
    }
    
    return urlPattern;
}

#pragma mark - HTTP Message File Creation

-(void)createHTTPMessageFileWithRequest:(NSURLRequest*)request response:(NSHTTPURLResponse*)response data:(NSData*)data atFilePath:(NSString *)filePath
{
    NSMutableString *dataString = NSMutableString.new;
    
    [dataString appendFormat:@"%@\n", [self statusLineFromResponse:response]];
     
    NSDictionary *headers = response.allHeaderFields;
    for(NSString *key in headers){
        [dataString appendFormat:@"%@: %@\n", key, headers[key]];
    }
    
    [dataString appendString:@"\n\n"];
    
    [dataString appendFormat:@"%@", data ? [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] : @""];
    
    BOOL created = [NSFileManager.defaultManager createFileAtPath:filePath contents:[dataString dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    [self.class updateRecorderProgressDelegate:created ? SWHTTPTrafficRecordingProgressRecorded : SWHTTPTrafficRecordingProgressFailedToRecord
                                      userInfo:@{SWHTTPTrafficRecordingProgressRequestKey: self.request,
                                                 SWHTTPTrafficRecordingProgressResponseKey: self.response,
                                                 SWHTTPTrafficRecordingProgressBodyDataKey: self.mutableData,
                                                 SWHTTPTrafficRecordingProgressFileFormatKey: @(SWHTTPTrafficRecordingFormatHTTPMessage),
                                                 SWHTTPTrafficRecordingProgressFilePathKey: filePath
                                                 }];
}

- (NSString *)statusLineFromResponse:(NSHTTPURLResponse*)response{
    CFHTTPMessageRef message = CFHTTPMessageCreateResponse(kCFAllocatorDefault, [response statusCode], NULL, kCFHTTPVersion1_1);
    NSString *statusLine = (__bridge_transfer NSString *)CFHTTPMessageCopyResponseStatusLine(message);
    return statusLine;
}

#pragma mark - Recording Progress 

+ (void)updateRecorderProgressDelegate:(SWHTTPTrafficRecordingProgressKind)progress userInfo:(NSDictionary *)info{
    SWHttpTrafficRecorder *recorder = [SWHttpTrafficRecorder sharedRecorder];
    if(recorder.progressDelegate && [recorder.progressDelegate respondsToSelector:@selector(updateRecordingProgress:userInfo:)]){
        [recorder.progressDelegate updateRecordingProgress:progress userInfo:info];
    }
}

@end

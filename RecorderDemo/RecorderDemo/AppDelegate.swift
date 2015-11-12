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

//  Created by Jinlian (Sunny) Wang on 11/11/15.

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SWHttpTrafficRecordingProgressDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        if let sharedRecorder = SWHttpTrafficRecorder.sharedRecorder() {
            sharedRecorder.recordingFormat = SWHTTPTrafficRecordingFormat.Mocktail
            sharedRecorder.progressDelegate = self
            sharedRecorder.startRecording()
        }
        return true
    }

    func updateRecordingProgress(currentProgress: SWHTTPTrafficRecordingProgressKind, userInfo info: [NSObject : AnyObject]!) {
        guard let request = info[SWHTTPTrafficRecordingProgressRequestKey] as? NSURLRequest, urlString = request.URL?.absoluteString else {
            return
        }
        
        let progress =  ["Received","Skipped","Started","Loaded","Recorded", "FailedToLoad", "FailedToRecord"][currentProgress.rawValue-1]
        
        if let path = info[SWHTTPTrafficRecordingProgressFilePathKey] as? String{
            print("Progress:\(progress), request: \(urlString) at \(path)")
        } else {
            print("Progress:\(progress), request: \(urlString)")
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


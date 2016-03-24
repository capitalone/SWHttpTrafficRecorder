/***********************************************************************************
* Copyright 2015 Capital One Services, LLC

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

class ViewController: UIViewController {

    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var browseWebView: UIWebView!

    override func viewDidLoad() {
        browseWebView.layer.borderColor = UIColor.grayColor().CGColor
        browseWebView.layer.borderWidth = 1

    }
    
    @IBAction func goButtonTapped(sender: AnyObject) {
        if let urlString = urlTextField.text, url = NSURL(string: urlString){
            browseWebView.loadRequest(NSURLRequest(URL: url))
        }
    }
    
    @IBAction func browseButtonTapped(sender: AnyObject) {
        urlTextField.text = "http://jsonplaceholder.typicode.com/"
        goButtonTapped(sender)
    }
    
    @IBAction func forwardTapped(sender: AnyObject) {
        browseWebView.goForward()
    }
    
    @IBAction func backTapped(sender: AnyObject) {
        browseWebView.goBack()
    }
    
}


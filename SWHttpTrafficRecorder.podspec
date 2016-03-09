#******************************************************************************
 # Copyright [yyyy] Capital One Services, LLC
 
 # Licensed under the Apache License, Version 2.0 (the "License");
 # you may not use this file except in compliance with the License.
 # You may obtain a copy of the License at
 
 # http://www.apache.org/licenses/LICENSE-2.0
 
 # Unless required by applicable law or agreed to in writing, software
 # distributed under the License is distributed on an "AS IS" BASIS,
 # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 # See the License for the specific language governing permissions and
 # limitations under the License.
 #
 #******************************************************************************/
 
Pod::Spec.new do |s|
  s.name         = "SWHttpTrafficRecorder"
  s.version      = "1.0"
  s.summary      = "A simple tool allowing to record your HTTP traffic for later use."
  s.description  = <<-DESC
                   SWHttpTrafficRecorder provides an easy way to record all the HTTP(s) traffic while the user is using your app at the same time.
                   DESC
  s.homepage     = "https://github.com/capitalone/SWHttpTrafficRecorder"
  s.license      = { :type => 'Apache Licnese 2.0', :file => 'LICENSE' }
  s.author       = { 'Sunny Wang' => 'wangjinlian@hotmail.com' }
  s.source       = { :git => "https://github.com/capitalone/SWHttpTrafficRecorder.git", :tag => 'v1.0' }
  s.platform     = :ios
  s.source_files = '*.{h,m}'
  s.ios.deployment_target = '7.0'
  s.requires_arc = true
end

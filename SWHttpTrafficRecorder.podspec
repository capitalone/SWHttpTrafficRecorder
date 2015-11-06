Pod::Spec.new do |s|
  s.name         = "SWHttpTrafficRecorder"
  s.version      = "0.5"
  s.summary      = "A simple tool allowing to record your HTTP traffic for later use."
  s.description  = <<-DESC
                   SWHttpTrafficRecorder provides an easy way to record all the HTTP(s) traffic while the user is using your app at the same time.
                   DESC
  s.homepage     = "http://www.capitalone.io/"
  s.license      = { :type => 'Apache Licnese 2.0', :file => 'LICENSE' }
  s.author       = { 'Sunny Wang' => 'wangjinlian@hotmail.com' }
  s.source       = { :git => "https://github.com/JinlianWang/SWHttpTrafficRecorder.git", :tag => 'v0.5' }
  s.platform     = :ios
  s.source_files = '*.{h,m}'
  s.requires_arc = true
end

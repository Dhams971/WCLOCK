
Pod::Spec.new do |s|

s.name         = "WClock"
s.version      = "1.0.0"
s.summary      = "WClock is a analog clock"
s.description  = "WClock is a customizable Analog clock that can be used in any iOS app."
s.homepage     =    "."

s.license      = "MIT"

s.author       = { "Dharmendra Solanki" => "dharmendra.solanki@volansystech.com" }

s.platform     = :ios, "9.0"

s.source       = { :git => "https://github.com/Dhams971/WClock.git", :tag => "1.0.0" }

s.source_files = "WClock", "WClock/**/*.{h,m,swift}"
s.exclude_files = "Classes/Exclude"


s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4' }



end

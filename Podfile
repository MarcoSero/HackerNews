source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'
inhibit_all_warnings!
use_frameworks!
link_with 'HackerNews', 'HackerNewsTests'

pod 'ComponentKit', '0.11'
pod 'CKComponentFadeTransition'
pod 'ReactiveCocoa', '4.0.0-RC.1'
pod 'FXReachability'

# Fix upload to iTunesConnect.
# See https://github.com/CocoaPods/CocoaPods/issues/4421
post_install do |installer|
  plist_buddy = "/usr/libexec/PlistBuddy"
  installer.pods_project.targets.each do |target|
    plist = "Pods/Target Support Files/#{target}/Info.plist"
    original_version = `#{plist_buddy} -c "Print CFBundleShortVersionString" "#{plist}"`.strip
    changed_version = original_version[/(\d+\.){1,2}(\d+)?/]
    unless original_version == changed_version
      puts "Fix version of Pod #{target}: #{original_version} => #{changed_version}"
      `#{plist_buddy} -c "Set CFBundleShortVersionString #{changed_version}" "Pods/Target Support Files/#{target}/Info.plist"`
    end
  end
end

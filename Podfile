# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!

def shared_pods
  # Pods for Street Art Orlando
  pod 'Alamofire', '~> 4.6.0', inhibit_warnings: true
  pod 'AlamofireImage', '~> 3.3.0', inhibit_warnings: true
  pod 'SnapKit', '~> 4.0.0'
  pod 'SwiftyJSON', '~> 4.0.0'
  pod 'PKHUD', '~> 5.0.0', inhibit_warnings: true
  pod 'Firebase/Core'
  pod 'Firebase/Crash'
end

target 'StreetArt' do
  inherit! :search_paths

  shared_pods
end

target 'StreetArt Dev' do
  inherit! :search_paths

  shared_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end

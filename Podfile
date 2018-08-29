# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'StreetArt' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for StreetArt
  pod 'Alamofire', '~> 4.6.0', inhibit_warnings: true
  pod 'AlamofireImage', '~> 3.3.0', inhibit_warnings: true
  pod 'SnapKit', '~> 4.0.0'
  pod 'SwiftyJSON', '~> 4.0.0'
  pod 'PKHUD', '~> 5.0.0'
  pod 'Firebase/Core'
  pod 'Firebase/Crash'

  target 'StreetArtTests' do
    inherit! :search_paths
    # Pods for testing
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end

# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

# Specify the project
project 'PrepSportsUSA.xcodeproj'

def shared_pods
  pod 'MaterialComponents/Buttons'
  pod 'MaterialComponents/TextControls+FilledTextAreas'
  pod 'MaterialComponents/TextControls+FilledTextFields'
  pod 'MaterialComponents/TextControls+OutlinedTextAreas'
  pod 'MaterialComponents/TextControls+OutlinedTextFields'
  pod 'RxSwift', '6.8.0'
  pod 'RxCocoa', '6.8.0'
  pod 'Alamofire'
  pod 'SwiftyJSON'
  pod 'IQKeyboardManagerSwift'
  pod 'JTAppleCalendar'
  pod 'Charts'
  pod 'GoogleMaps'
  pod 'Google-Maps-iOS-Utils'
  pod 'PrettyCards'
  pod 'Fastis'
  pod 'SDWebImage'
  
end

# PrepSportsUSA Target
target 'PrepSportsUSA' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for PrepSportsUSA
  shared_pods

  target 'PrepSportsUSA_Dev' do
    inherit! :complete
    # Inherits all pods from parent target
  end
end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
               end
          end
   end
end

# Uncomment this line to define a global platform for your project
 platform :ios, '9.0'
# Uncomment this line if you're using Swift
 use_frameworks!

target 'Petsee' do
    pod 'AlamofireImage', '~> 2.0'
    pod 'XLForm', '~> 3.0'
    pod 'ImagePicker'
    pod 'SVProgressHUD'
    pod 'HCSStarRatingView', '~> 1.4.5'
end

target 'PetseeCore' do
    link_with 'Petsee'

    pod 'ObjectMapper'
end

target 'PetseeNetwork' do
    link_with 'Petsee'

    pod 'Alamofire', '~> 3.3'
    pod 'Moya'
    pod 'Moya/RxSwift'
    pod 'Moya-ObjectMapper/RxSwift'
end


# Uncomment the next line to define a global platform for your project

source 'https://github.com/CocoaPods/Specs.git'

def network
  pod 'Alamofire', '~> 5.8'
end

def rx
  pod 'RxSwift', '6.5.0'
  pod 'RxCocoa', '6.5.0'
  pod 'RxDataSources'
  pod 'Action'
end

target 'PokemonTes' do
  platform :ios, '14.0'
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  network
  rx
  pod 'SnapKit', '~> 5.0.0'
  pod 'RealmSwift', '~>10'
  pod 'SnackBar.swift'
  pod 'Kingfisher', '~> 7.0'
  pod 'MBProgressHUD'
  pod 'XLPagerTabStrip', '~> 9.0'
  pod 'SkeletonView'

  target 'PokemonTesTests' do
    inherit! :search_paths
    

  end

  target 'PokemonTesUITests' do
    # Pods for testing
  end

end

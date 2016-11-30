platform :ios, '9.0'

target 'SimpleWeather' do
  use_frameworks!
  pod 'SBTUITestTunnel/Server'

  target 'SimpleWeatherTests' do
    inherit! :search_paths
  end

  target 'SimpleWeatherUITests' do
    inherit! :search_paths
    pod 'SBTUITestTunnel/Client'
  end

end

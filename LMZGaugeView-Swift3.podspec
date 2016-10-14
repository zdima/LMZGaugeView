Pod::Spec.new do |s|

  s.name         = "LMZGaugeView-Swift3"
  s.version      = "0.0.2"
  s.summary      = "LMZGaugeView is a simple and customizable gauge control for OSX."

  s.description  = <<-DESC
LMZGaugeView is a simple and customizable gauge control for OS X inspired by [LMGaugeView for iOS by LMinh](https://github.com/lminhtm/LMGaugeView).
                   DESC

  s.homepage     = "https://github.com/zdima/LMZGaugeView.git"
  s.screenshots  = "https://raw.githubusercontent.com/zdima/LMZGaugeView/master/screen.png"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Dmitriy Zakharkin" => "mail@zdima.net" }
  s.platform     = :osx
  s.osx.deployment_target = "10.11"
  s.source       = { :git => "https://github.com/zdima/LMZGaugeView.git", :tag => "SW3.#{s.version}" }
  s.source_files = "LMZGaugeView/*.{swift}"
  s.resource     = "LMZGaugeView/**/*.{strings}"

end

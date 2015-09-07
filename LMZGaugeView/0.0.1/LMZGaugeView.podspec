Pod::Spec.new do |s|

  s.name         = "LMZGaugeView"
  s.version      = "0.0.1"
  s.summary      = "LMZGaugeView is a simple and customizable gauge control for iOS."

  s.description  = <<-DESC
LMZGaugeView is a simple and customizable gauge control for OS X inspired by [LMGaugeView for iOS by LMinh](https://github.com/lminhtm/LMGaugeView).
                   DESC

  s.homepage     = "https://github.com/zdima/LMZGaugeView.git"
  s.screenshots  = "https://raw.githubusercontent.com/zdima/LMZGaugeView/master/screen.png"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Dmitriy Zakharkin" => "mail@zdima.net" }
  s.platform     = :osx
  s.osx.deployment_target = "10.10"
  s.source       = { :git => "https://github.com/zdima/LMZGaugeView.git", :tag => "0.0.1" }
  s.source_files = "LMZGaugeView/*.{swift}"
  s.resource     = "LMZGaugeView/**/*.{strings}"

end

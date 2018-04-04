Pod::Spec.new do |s|

  s.name         = "YFJSON"
  s.version      = "1.0"
  s.summary      = "Easy way to deal with JSON writen on Swift"

  s.homepage     = "https://github.com/YuriFox/YFJSON"

  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "YuriFox" => "yuri17fox@gmail.com" }

  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/YuriFox/YFJSON.git", :tag => s.version.to_s }
  
  s.source_files = "YFJSON/JSON.swift"

end

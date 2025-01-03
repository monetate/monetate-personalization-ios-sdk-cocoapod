#
#  Be sure to run `pod spec lint monetate-ios-sdk.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "monetate-ios-sdk"
  s.version      = "2025.01.02"
  s.summary      = "Provides convenient access to the Engine API"
  s.description  = "Monetate Personalization, powered by Monetate and Certona, is the leading personalization software, recognized by key industry analysts.
From sophisticated A/B testing to AI-driven personalization, harness patented technology to delight your customers with impactful individualized experiences, resulting in increased engagement, conversions, and lifetime value.
Join the 1,000+ brands growing their revenue with Monetate"
  
  s.homepage     = "https://www.monetate.com"
  s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author       = { "Monetate" => "info@monetate.com" }
  
  s.platform     = :ios
  s.ios.deployment_target = "12.0"
  
  s.source       = { 
    :git => "https://github.com/monetate/monetate-personalization-ios-sdk-cocoapod.git",
    :tag => s.version.to_s 
  }
  
  s.source_files = "monetate/**/*"
  s.swift_version = "5.0"
  
  # Private pod specific configurations
  s.static_framework = true
  s.requires_arc = true
  
end
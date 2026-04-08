Pod::Spec.new do |s|
  s.name             = 'JAPinView'
  s.version          = '1.0.0'
  s.summary          = 'Modern OTP / PIN input view with AutoFill, paste support, and accessibility.'

  s.description      = <<-DESC
JAPinView is a modern, customizable OTP and PIN input component for iOS.
Supports SMS AutoFill, paste detection, secure entry, accessibility,
animations, and Flutter embedding compatibility.
  DESC

  s.homepage         = 'https://github.com/JayachandraA/JAPinView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'JayachandraA' => 'ajchandra15@gmail.com' }

  s.source           = {
    :git => 'https://github.com/JayachandraA/JAPinView.git',
    :tag => s.version.to_s
  }

  # ✅ Modern platform target (matches SPM)
  s.platform         = :ios, '15.0'

  # ✅ Swift version aligned with Xcode 15/16
  s.swift_version    = '5.9'

  # ✅ Shared source folder (Pods + SPM)
  s.source_files     = 'Sources/JAPinView/**/*.{swift}'

  # Optional but recommended
  s.requires_arc     = true

end

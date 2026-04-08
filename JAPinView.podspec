Pod::Spec.new do |s|

  s.name             = 'JAPinView'
  s.version          = '1.0.0'
  s.summary          = 'A lightweight, fully configurable PIN / OTP entry view for iOS, written in Swift.'

  s.description      = <<-DESC
    JAPinView is a production-ready PIN and OTP input field for iOS.
    Drop it in, set a configuration, and get:
      - 5 built-in styles: boxed, underlined, rounded, filled, and fully custom
      - Per-state theming with independent colours for empty, focused, filled, error, and disabled states
      - Async validation with automatic loading, success, and failure handling
      - Configurable animations: scale, bounce, fade, shake or none — per event
      - Blinking cursor on the active cell
      - Secure entry with any masking symbol
      - SMS AutoFill via textContentType = .oneTimeCode
      - Full VoiceOver support with per-cell labels and live announcements
      - Dynamic Type and Reduce Motion support
      - Zero dependencies — pure UIKit
  DESC

  s.homepage         = 'https://github.com/JayachandraA/JAPinView'
  s.screenshots      = [
    'https://raw.githubusercontent.com/JayachandraA/JAPinView/master/Example/example1.png',
    'https://raw.githubusercontent.com/JayachandraA/JAPinView/master/Example/example2.png',
    'https://raw.githubusercontent.com/JayachandraA/JAPinView/master/Example/example3.png',
    'https://raw.githubusercontent.com/JayachandraA/JAPinView/master/Example/example4.png',
    'https://raw.githubusercontent.com/JayachandraA/JAPinView/master/Example/example5.png'
  ]

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jayachandra Agraharam' => 'ajchandra15@gmail.com' }
  s.source           = {
    :git  => 'https://github.com/JayachandraA/JAPinView.git',
    :tag  => s.version.to_s
  }

  s.social_media_url = 'https://github.com/JayachandraA'

  s.ios.deployment_target = '15.0'
  s.swift_versions        = ['5.7', '5.8', '5.9', '5.10']

  s.source_files     = 'Sources/JAPinView/**/*.{swift}'

  s.frameworks    = 'UIKit'
  s.requires_arc  = true

end

Pod::Spec.new do |s|
  s.name         = 'SwiftTerm'
  s.version      = '1.0.0'
  s.summary      = 'A terminal emulator for Swift applications'
  s.description  = 'SwiftTerm provides a terminal emulator and terminal widget for Swift applications.'
  s.homepage     = 'https://github.com/migueldeicaza/SwiftTerm'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Miguel de Icaza' => 'miguel.de.icaza@gmail.com' }
  s.source       = { :git => 'https://github.com/migueldeicaza/SwiftTerm.git', :branch => 'main' }
  s.source_files = 'Sources/SwiftTerm/**/*.swift'
  s.platform     = :ios, '13.0'
  s.swift_version = '5.0'
end

$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'wmq/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  # Exclude locally compiled files since they are platform specific
  excludes = [
    /lib.wmq.constants\.rb/,
    /lib.wmq.constants_admin\.rb/,
    /ext.wmq_structs\.c/,
    /ext.wmq_reason\.c/,
    /ext.Makefile/,
    /ext.*\.o/,
    /ext.*\.so/,
    /ext.*\.bundle/,
    /ext.mkmf\.log/
  ]
  s.name        = 'rubywmq'
  s.version     = WMQ::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Reid Morrison']
  s.email       = ['reidmo@gmail.com']
  s.homepage    = 'https://github.com/reidmorrison/rubywmq'
  s.summary     = 'Native Ruby interface into IBM MQ (formerly WebSphere MQ)'
  s.description = 'RubyWMQ is a high performance native Ruby interface into IBM MQ (formerly WebSphere MQ).'
  s.license     = 'Apache-2.0'

  # Only package the library sources; dev/test tooling (Docker, deps/, test/) stays out of the gem
  s.files = Dir['lib/**/*.rb', 'ext/**/*.{c,h,rb,erb}', 'examples/**/*', 'LICENSE.txt', 'README.md', 'Rakefile', '.document']
    .reject { |f| File.directory?(f) || excludes.any? { |re| f =~ re } }

  s.extensions << 'ext/extconf.rb'
  s.requirements << 'IBM MQ (WebSphere MQ) v7 or later Client or Server with Development Kit'
  s.required_ruby_version = '>= 3.0'
end

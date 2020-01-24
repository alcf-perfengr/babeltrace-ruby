Gem::Specification.new do |s|
  s.name = 'babeltrace'
  s.version = "0.1.1"
  s.author = "Brice Videau"
  s.email = "bvideau@anl.gov"
  s.homepage = "https://github.com/alcf-perfengr/babeltrace-ruby"
  s.summary = "Ruby libbabeltrace bindings"
  s.description = "Ruby libbabeltrace ffi bindings"
  s.files = Dir[ 'babeltrace.gemspec', 'LICENSE', 'lib/**/**/*.rb', 'ext/**/*.rb', 'ext/**/*.c', 'ext/**/**/*.h'  ]
  s.extensions << 'ext/babeltrace_c/extconf.rb'
  s.has_rdoc = false
  s.license = 'MIT'
  s.required_ruby_version = '>= 2.3.0'
  s.add_dependency 'ffi', '~> 1.9', '>=1.9.3'
end

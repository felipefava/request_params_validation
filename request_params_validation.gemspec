lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'request_params_validation/version'

Gem::Specification.new do |spec|
  spec.name          = 'request_params_validation'
  spec.version       = RequestParamsValidation::VERSION
  spec.authors       = 'Felipe Fava'
  spec.email         = 'felipefava5@gmail.com'
  spec.homepage      = 'https://github.com/felipefava/request_params_validation'
  spec.license       = 'MIT'

  spec.summary       = 'Validates rails request params'
  spec.description   = 'It validates request params outside your controller logic in order to ' \
                       'get a clean and nice code, and also helping with the documentation of ' \
                       'the operations.'

  spec.files         = Dir['{lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_dependency 'rails', '>= 3'
end

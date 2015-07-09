# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'framed_uploader/version'

Gem::Specification.new do |spec|
  spec.name          = "framed_uploader"
  spec.version       = FramedUploader::VERSION
  spec.authors       = ["Andrew Berls"]
  spec.email         = ["andrew.berls@gmail.com"]
  spec.summary       = %q{Framed user data uploader}
  spec.description   = %q{Framed user data uploader}
  spec.homepage      = ""
  spec.license       = ""

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'aws-sdk', '~> 2'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end

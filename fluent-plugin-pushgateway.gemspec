# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-pushgateway"
  spec.version       = "0.2.0"
  spec.authors       = ["Mitsuhiro Tanda", "Charlie Moad"]
  spec.email         = ["mitsuhiro.tanda@gmail.com", "charlie.moad@geofeedia.com"]

  spec.summary       = %q{Fluentd plugin to send metrics to Prometheus Pushgateway.}
  spec.description   = %q{Fluentd plugin to send metrics to Prometheus Pushgateway.}
  spec.homepage      = "https://github.com/geofeedia/fluent-plugin-pushgateway"
  spec.licenses      = ["MIT"]

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "fluentd"
  spec.add_runtime_dependency "prometheus-client"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "test-unit"
end

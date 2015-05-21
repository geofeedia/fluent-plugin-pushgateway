Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-prometheus-pushgateway"
  spec.version       = "0.1.0"
  spec.authors       = ["Mitsuhiro Tanda"]
  spec.email         = ["mitsuhiro.tanda@gmail.com"]

  spec.summary       = %q{Fluentd plugin to send metrics to Prometheus Pushgateway.}
  spec.description   = %q{Fluentd plugin to send metrics to Prometheus Pushgateway.}
  spec.homepage      = "https://github.com/mtanda/fluent-plugin-prometheus-pushgateway"
  spec.licenses      = ["MIT"]

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "fluentd"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end

require 'prometheus/client'
require 'prometheus/client/registry'
require 'prometheus/client/push'

module Fluent
  class PrometheusPushgatewayOutput < Output
    Plugin.register_output('prometheus_pushgateway', self)

    config_param :host, :string,  :default => '127.0.0.1'
    config_param :port, :integer, :default => 9091

    def initialize
      super
    end

    def configure(conf)
      super
      @gateway = "http://#{@host}:#{@port}"
    end

    def emit(tag, es, chain)
      registry = Prometheus::Client::Registry.new

      es.each do |time, record|
        gauge = Prometheus::Client::Gauge.new(record['name'].to_sym, "dummy")
        registry.register(gauge)
        gauge.set({}, record['value'])
        Prometheus::Client::Push.new(record['job'], record['instance'], @gateway).add(registry)
      end

      chain.next
    end
  end
end

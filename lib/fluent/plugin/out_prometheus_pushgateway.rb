require 'prometheus/client'
require 'prometheus/client/registry'
require 'prometheus/client/push'

module Fluent
  class PrometheusPushgatewayOutput < Output
    Plugin.register_output('prometheus_pushgateway', self)

    config_param :host, :string,  :default => '127.0.0.1'
    config_param :port, :integer, :default => 9091
    config_param :job_key, :string, :default => 'job'
    config_param :instance_key, :string, :default => 'instance'
    config_param :name_key, :string, :default => 'name'
    config_param :label_keys, :string, :default => '' # comma separated
    config_param :value_key, :string, :default => 'value'

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
        gauge = Prometheus::Client::Gauge.new(record[@name_key].to_sym, "dummy")
        registry.register(gauge)
        gauge.set({}, record[@value_key])
        Prometheus::Client::Push.new(record[@job_key], record[@instance_key], @gateway).add(registry)
      end

      chain.next
    end
  end
end

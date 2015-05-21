require 'net/http'

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
    end

    def emit(tag, es, chain)
      es.each do |time, record|
        req = Net::HTTP::Post.new(path)
        req.body = messages.join("\n")

        res = Net::HTTP.new(@host, @port.to_i).start do |http|
          http.request(req)
        end
      end

      chain.next
    end
  end
end

require 'fluent/output'
require 'prometheus/client'
require 'prometheus/client/push'

class Fluent::PushgatewayOutput < Fluent::BufferedOutput
  Fluent::Plugin.register_output('pushgateway', self)

  config_param :host,     :string,  :default => '127.0.0.1'
  config_param :port,     :integer, :default => 9091
  config_param :job,      :string,  :default => 'pushgateway'
  config_param :instance, :string,  :default => 'fluentd'

  def initialize
    super
  end

  def configure(conf)
    super
    @gateway = "http://#{@host}:#{@port}"

  end

  def start
    super
  end

  def format(tag, time, record)
    [tag, time, record].to_msgpack
  end

  def shutdown
    super
  end

  def write(chunk)
    registry = Prometheus::Client:Registry.new

    chunk.msgpack_each do |tag, time, record|
      begin
        labels = standard_labels(record)

        record.each do |key, value|

          # Look for specific keys that we know how to map to metrics
          if /(count|error|success)<(int|long)>$/.match key
            key_sym = key_symbol(key)
            counter = registry.exist? key_sym ? registry.get(key_sym) : registry.counter(key_sym, 'counter')
            counter.increment(labels, value)

          elsif /(duration|size|took)<(int|long)>$/.match key
            key_sym = key_symbol(key)
            histogram = registry.exist? key_sym ? registry.get(key_sym) : registry.histogram(key_sym, 'histogram')
            histogram.observe(labels, value)
            
          end

        end

      rescue => e
        $log.error("Pushgateway Error:", :error_class => e.class, :error => e.message)
        # $log.error(e.backtrace)
      end
    end

    Prometheus::Client::Push.new(@job, @instance, @gateway).add(registry)
  end
end

def standard_labels(record)
  labels = {}

  labels[:service] = record['service'] if record.has_key? 'service'
  labels[:release] = record['release'] if record.has_key? 'release'

  record.each do |key, value|
    if key.start_with? 'placement.'
      labels[key.gsub(/\./, '_').to_sym] = value
    end
  end

  return labels
end

def key_symbol(key, record)
  key_base = key.gsub(/<(\w+)>$/, '').gsub(/\./, '_') # remove the type identifier suffix and replace periods

  if record.has_key? 'schema' && record['schema'] == 'woodpecker.v1'
    # combine module_submodule_action_key
    return ([ record['module'], record['submodule'], record['action'], key_base ] * '_').to_sym
  end

  return key_base.to_sym
end

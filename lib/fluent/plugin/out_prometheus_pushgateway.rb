require 'fluent/output'
require 'prometheus/client'
require 'prometheus/client/push'

class Fluent::PushgatewayOutput < Fluent::BufferedOutput
  Fluent::Plugin.register_output('pushgateway', self)

  config_param :host, :string,  :default => '127.0.0.1'
  config_param :port, :integer, :default => 9091
  config_param :job,  :string,  :default => 'pushgateway'  

  def initialize
    super
  end

  def configure(conf)
    super
    @gateway = "http://#{@host}:#{@port}"

    # # counters
    # @count_counter = Prometheus::Client::Counter.new(:count, 'Counters')
    # @status_counter = Prometheus::Client::Counter.new(:status, 'Response status codes')
    # @success_counter = Prometheus::Client::Counter.new(:success, 'Successful response counter')
    # @error_counter = Prometheus::Client::Counter.new(:error, 'Error response counter')

    # # histograms
    # @took_histogram = Prometheus::Client::Histogram(:took, 'Response time for an API call')
    # @duration_histogram = Prometheus::Client::Histogram(:duration, 'Response time for a call')
    # @size_histogram = Prometheus::

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
    chunk.msgpack_each do |tag, time, record|
      begin
        
        if record.has_key?('level') && record['level'].downcase.eql?('info')
          labels = record_labels(record)

          record.each do |key, value|

            # Look for specific keys that we know how to map to metrics
            if /(count|error|success)<(int|long)>$/.match key
              counter = Prometheus::Client::Counter.new(key)
              Prometheus::Client.registry.register(counter)
              counter.increment(labels, value)
              Prometheus::Client::Push.new(@job, nil, @gateway).add(Prometheus::Client.registry)

            elsif /(duration|size|took)<(int|long)>$/.match key
              histogram = Prometheus::Client::Histogram.new(key)
              Prometheus::Client.registry.register(histogram)
              histogram.observe(labels, value)
              Prometheus::Client::Push.new(@job, nil, @gateway).add(Prometheus::Client.registry)
            end

          end
        end

      rescue => e
        $log.error("Pushgateway Error:", :error_class => e.class, :error => e.message)
      end
    end
  end
end

def record_labels(record)
  labels = {}

  labels['service'] = record['service'] || nil
  labels['release'] = record['release'] || nil

  record.each do |key, value|
    if key.starts_with? 'placement.'
      labels[key] = value
    end
  end

  # check for known schemas
  if record.has_key? 'schema'
    if record['schema'] == 'woodpecker.v1'
      labels['module'] = record['module'] || nil
      labels['submodule'] = record['submodule'] || nil
      labels['action'] = record['action'] || nil
    end
  end
end

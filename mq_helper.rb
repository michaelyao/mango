require 'rubygems'
require 'mq'
require 'benchmark'

# http://weblog.asceth.com/2009/02/13/ruby-amqp-rabbitmq-for-data-processing-win.html

class Integer
  def paged_collect(mod)
    acc = Hash.new
    self.times do |num|
      index = num % mod
      acc[index] = Array.new unless acc[index]
      acc[index] = acc[index] << num
    end
    acc
  end
end

module MQHelper

  def log message
    puts "#{MQ.id}: #{message}"
    $stdout.flush
  end

  def logp *args
    print args
    $stdout.flush
  end

  def graceful_death
    AMQP.stop{ EM.stop }
    exit(0)
  end

  protected

  def load_rails_environment
    mark = Benchmark.realtime do
      require 'config/environment'
    end
    log "loaded rails environment... #{mark} seconds"
  end

  def infrastructure(&block)
    mark = Benchmark.realtime do
      block.call
    end
    log "loading required infrastructure... #{mark} seconds"
  end

  def calc_pages(total, offset)
    if total < offset
      1
    else
      (total / offset).to_i
    end
  end

  def calc_modulus(total_pages)
    if total_pages < 100
      3 + (total_pages/10).to_i
    else
      13 + (total_pages/10).to_i
    end
  end

  def serialize data
    Marshal.dump(data)
  end

  def unserialize data
    autoload_missing_constants do
      Marshal.load data
    end
  end

  def autoload_missing_constants
    yield
  rescue ArgumentError => error
    lazy_load ||= Hash.new {|hash, hash_key| hash[hash_key] = true; false}
    if error.to_s[/undefined class|referred/] && !lazy_load[error.to_s.split.last.constantize]
      retry
    else
      raise error
    end
  end

end
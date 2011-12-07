#!/usr/bin/ruby

# http://weblog.asceth.com/2009/02/13/ruby-amqp-rabbitmq-for-data-processing-win.html
ttrc5z z 
# Core
require 'date'
require 'benchmark'

# Gems
require 'rubygems'
require 'mq'

# Helper
require 'import.mq.helper.rb'

# For ack to work appropriatly you must shutdown AMQP gracefully,
# otherwise all items in your queue will be returned
Signal.trap('INT') {
  AMQP.stop{ EM.stop }
  exit(0)
}
Signal.trap('TERM') {
  AMQP.stop{ EM.stop }
  exit(0)
}

AMQP.start do

  class Reporter

    attr_reader :options
    @timer = nil

    include MQHelper

    def initialize env
      @options = env

      load_rails_environment
    end

    def report
      section = ARGV[0]

      if section.nil?
        log "You must supply a section to report (users, clients, etc..)"
        graceful_death
      else
        case section
        when "users"
          report_user
        when "clients"
          report_client
        end
      end
    end # end report

    protected

    def report_user
      mq = MQ.new
      queue = mq.queue('cltc.import.users').bind(mq.topic('cltc'), :key => 'import.users')

      run_report(queue)
    end # end report user

    def report_client
      mq = MQ.new
      queue = mq.queue('cltc.import.clients').bind(mq.topic('cltc'), :key => 'import.clients')

      run_report(queue)
    end

    def run_report(queue)
      @timer = EM.add_periodic_timer(5) {
        queue.status {|num_messages, num_consumers|
          log "[#{Time::now.strftime('%m/%d - %H:%M:%S')}]  #{num_consumers} consumers have #{num_messages} messages left to process"
        }
      }
    end # end run report

  end # end Reporter

  Reporter.new(ENV).report
end # end AMQP.start
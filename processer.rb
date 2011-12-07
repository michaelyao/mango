#!/usr/bin/ruby

# http://weblog.asceth.com/2009/02/13/ruby-amqp-rabbitmq-for-data-processing-win.html

# Core
require 'date'

# Gems
require 'rubygems'
require 'mq'

# Helper
require 'import.mq.helper.rb'

# For ack to work appropriatly you must shutdown AMQP gracefully,
# otherwise all items in your queue will be returned
Signal.trap('INT') {
  unless EM.forks.empty?
    EM.forks.each do |pid|
      Process.kill('KILL', pid)
    end
  end
  AMQP.stop{ EM.stop }
  exit(0)
}
Signal.trap('TERM') {
  unless EM.forks.empty?
    EM.forks.each do |pid|
      Process.kill('KILL', pid)
    end
  end
  AMQP.stop{ EM.stop }
  exit(0)
}

# spawn workers
workers = ARGV[1] ? (Integer(ARGV[1]) rescue 1) : 1
puts "workers: #{workers}"
EM.fork(workers) do
  AMQP.start do

    class Processer

      attr_reader :options

      include MQHelper

      def initialize env
        @options = env

        load_rails_environment
      end

      # entry point - `process.rb "users"`
      def process
        section = ARGV[0]

        if section.nil?
          log "You must supply a section to process (users, clients, etc..)"
          graceful_death
        else
          case section
          when "users"
            process_user
          when "clients"
            infrastructure do
              require 'client_loader'
            end
            process_client
          end
        end
      end # end process

      protected

      # update legacy users to new users model
      def process_user
        mq = MQ.new
        # open a queue (name can be anything)
        # and then bind it to the topic exchange 'conversion'
        # and routing key 'import.users'.
        queue = mq.queue('cltc.import.users').bind(mq.topic('conversion'), :key => 'import.users')

        run_process(queue) do |user|
          new_user = User.find_by_login(user.login) || User.new
          new_user.login = user.login
          new_user.password = new_user.password_confirmation = user.password

          new_user.save false
        end
      end # end process user

      # update legacy clients to new clients model
      def process_client
        mq = MQ.new
        queue = mq.queue('cltc.import.clients').bind(mq.topic('cltc'), :key => 'import.clients')

        run_process(queue) do |client|
          ClientLoader.new client
        end
      end # end process client

      def run_process(queue, &block)
        queue.subscribe(:ack => true) { |headers, payload|
          data = unserialize(payload)
          block.call(data)
          headers.ack
        }
      end # end run process

    end # end Processer

    Processer.new(ENV).process
  end # end AMQP.start
end # end EM.fork

# wait on forks
while !EM.forks.empty?
  sleep(5)
end
#!/usr/bin/ruby

# http://weblog.asceth.com/2009/02/13/ruby-amqp-rabbitmq-for-data-processing-win.html

# Core
require 'date'

# Gems
require 'rubygems'
require 'mq'

# Helper
require 'import.mq.helper.rb'

# Shutdown AMQP gracefully so messages are published
Signal.trap('INT') { AMQP.stop{ EM.stop } }
Signal.trap('TERM'){ AMQP.stop{ EM.stop } }

class Publisher

  attr_reader :options

  include MQHelper

  # Need rails for our models
  def initialize env
    load_rails_environment
  end

  # entry point - ` publish.rb "users" ` will publish the users
  def publish
    section = ARGV[0]

    if section.nil?
      log "You must supply a section to publish (users, clients, etc..)."
      graceful_death
    else
      case section
      when "users"
        publish_users
      when "clients"
        publish_clients
    end
  end

  protected

  def publish_users
    total = Legacy::User.count
    log "publishing #{total} users..."

    # We know the user count is small so we don't do
    # any pagination and instead load it all at once
    # and publish
    lusers = Legacy::User.all

    # start amqp
    AMQP.start do
      # create/grab our exchange 'conversion' which is a topic exchange
      topic = MQ.new.topic('conversion')

      # for each legacy user, publish its dump with the routing key 'import.users'
      lusers.each do |user|
        logp "publishing #{user.login}..."
        topic.publish(serialize(user), :key => 'import.users')
        log "OK!"
      end

      # We're done so tell amqp and eventmachine to finish publishing and then stop
      AMQP.stop do
        EM.stop
      end
    end
  end # end publish users

  def publish_clients
    # calculate the number of times (pages) we need to loop with a 100 row offset/limit
    total_count = Legacy::Client.count
    number_of_pages = calc_pages(total_count, 100)
    log "publishing #{total_count} clients in #{number_of_pages} pages..."

    # Publishes a set of pages, allows eventmachine/amqp to send them
    # then restarts the process with another set of pages.
    modulus = calc_modulus(number_of_pages)
    number_of_pages.paged_collect(modulus).each_value do |pages|
      AMQP.start do
        pages.each do |page|
          lclients = Legacy::Client.all(:limit => 100, :offset => page*100)

          topic = MQ.new.topic('conversion')
          lclients.map do |lclient|
            topic.publish(serialize(lclient), :key => 'import.clients')
          end
          log "published page #{page} of #{number_of_pages} for clients..."
        end
        AMQP.stop do
          EM.stop
        end
      end
    end
  end # end publish clients

end

Publisher.new(ENV).publish
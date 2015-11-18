require 'sinatra'
require 'sinatra/contrib'
require 'cf-app-utils'
require 'redis'
require 'singleton'

class Analytics
  include Singleton

  attr_accessor :redis_connection

  def redis
    @redis_connection ||= Redis.new(redis_creds)
  end

  def redis_creds
    begin
      creds = CF::App::Credentials
        .find_all_by_all_service_tags(['redis', 'pivotal'])
        .first
      return {
        host:     creds.fetch('host'),
        port:     creds.fetch('port'),
        password: creds.fetch('password')
      }
    rescue
      {}
    end
  end

  def visit!
    redis.incr('visits')
  end
end

set :bind, '0.0.0.0'
set :port, ENV['PORT'] || 4567

get '/' do
  json(
  	instance: ENV['CF_INSTANCE_INDEX'],
  	visits:   Analytics.instance.visit!
  )
end
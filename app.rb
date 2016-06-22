require 'sinatra'
require 'sinatra/contrib'
require 'redis'
require 'singleton'

class Analytics
  include Singleton

  attr_accessor :redis_connection

  def redis
    @redis_connection ||= Redis.new(redis_creds)
  end

  def redis_creds
    return {
      host: ENV['REDIS_SERVICE_HOST'],
      port: ENV['REDIS_SERVICE_PORT']
    }
  end

  def visit!
    redis.incr('visits')
  end
end

set :bind, '0.0.0.0'
set :port, ENV['PORT'] || 4567

get '/' do
  json(
    instance: ENV['HOSTNAME'],
  	visits:   Analytics.instance.visit!
  )
end

get '/ouch' do
  Process.exit!(true)
end

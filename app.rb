require 'sinatra'
require 'sinatra/contrib'

get '/' do
  json instance: ENV['CF_INSTANCE_INDEX']
end
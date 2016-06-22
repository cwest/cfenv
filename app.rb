require 'sinatra'
require 'sinatra/contrib'

set :bind, '0.0.0.0'
set :port, ENV['PORT'] || 4567

get '/' do
  json instance: ENV['HOSTNAME']
end
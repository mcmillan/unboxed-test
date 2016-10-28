require 'sinatra'
require_relative 'boot'

set :erb, layout: :'layouts/favourites'

get '/' do
  erb :index
end

post '/' do
  @user = User.new(params[:username])
  erb :results
end

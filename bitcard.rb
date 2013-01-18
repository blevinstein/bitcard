require 'sinatra/base'
require 'sinatra/contrib'

require 'haml'
require 'json'

require './config.rb'

class Bitcard < Sinatra::Base
  set :port, 8080
  set :environment, $environment
  set :public_folder, 'public'
  enable :sessions

  set :haml, :layout => :template
  register Sinatra::Contrib

  get '/' do
    haml :index
  end

  get '/code/:id' do
    code = Code.get(params[:id])
    if code
      {:success => true, :amount => code.amount}
    else
      {:success => false}
    end.to_json
  end

  post '/send' do
    params.to_json
  end

  run! if app_file == $0
end

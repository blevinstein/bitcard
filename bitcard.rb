require 'sinatra/base'
require 'sinatra/contrib'
require 'sinatra/config_file'

require 'haml'
require 'json'

require './config.rb'
require './bitcoin_rpc.rb'

class Bitcard < Sinatra::Base
  register Sinatra::ConfigFile
  config_file 'config.yml'
  set :port, 8080
  set :environment, settings.environment
  set :public_folder, 'public'
  set :raise_errors, false
  set :show_exceptions, false
  enable :sessions

  set :haml, :layout => :template
  register Sinatra::Contrib

  def require_admin
    redirect '/login' unless session[:admin]
    @admin = Admin.get(session[:admin])
    fail if @admin.nil?
  end

  get '/login' do
    redirect '/admin' if session[:admin]
    haml :login
  end

  post '/login' do
    admin = Admin.get(params[:username])
    if admin && admin.password?(params[:password])
      session[:admin] = admin.username
      redirect '/admin'
    else
      @flash = 'Incorrect username or password.'
      haml :login
    end
  end

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

  get '/admin' do
    require_admin
    haml :admin
  end

  post '/send' do
    params.to_json
  end

  def rpc
    @rpc ||= begin
      s = settings.bitcoind
      BitcoinRPC.new("http://#{s[:user]}:#{s[:password]}@#{s[:host]}:#{s[:port]}")
    end
  end

  run! if app_file == $0
end

require 'sinatra/base'
require 'sinatra/contrib'
require 'sinatra/config_file'

require 'logger'

require 'haml'
require 'json'
require 'pp'

require './string.rb'
require './config.rb'
require './bitcoin_rpc.rb'

class Bitcard < Sinatra::Base
  register Sinatra::ConfigFile
  config_file 'config.yml'
  set :port, 8080
  set :environment, $environment
  set :public_folder, 'public'
  set :raise_errors, false
  set :show_exceptions, true
  enable :sessions, :logging
  # TODO: Add logging messages

  set :haml, :layout => :template
  register Sinatra::Contrib

  get '/' do
    @input = 'Challenge'
    haml :index
  end

  post '/' do
    @hidden = []
    @challenge = params['challenge']
    if not @challenge
      @input = 'Challenge'
      return haml :index
    end
    code = Code.get(params['challenge'])
    if not code
      @input = 'Challenge'
      @message = 'Unrecognized challenge.'
      return haml :index
    end
    @hidden << 'challenge'
    @answer = code.response
    @secret = params['secret']
    if not @secret
      @input = 'Secret'
      return haml :index
    end
    if @secret != code.secret
      @input = 'Secret'
      @message = 'Invalid code.'
      return haml :index
    end
    @hidden << 'secret'
    @amount = code.amount
    @address = params['address']
    if not @address
      @input = 'Address'
      return haml :index
    end
    # if not valid address
    # send bitcoins to address
    @hidden = []
    @input = 'Challenge'
    @message = 'Sent! Enter a new challenge to send more bitcoins.'
    haml :index
  end
  
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

  get '/admin' do
    require_admin
    haml :admin
  end

  def rpc
    @rpc ||= begin
      s = settings.bitcoind
      BitcoinRPC.new("http://#{s[:user]}:#{s[:password]}@#{s[:host]}:#{s[:port]}")
    end
  end

  run! if app_file == $0
end

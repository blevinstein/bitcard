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
  enable :logging
  #TODO: add thorough logging messages

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
    # TODO: if not valid address
    Code.rpc.sendfrom(code.to_s, @address, code.amount)
    code.delete
    @hidden = []
    @input = 'Challenge'
    @message = 'Sent! Enter a new challenge to send more bitcoins.'
    haml :index
  end
  
  def require_admin
    session = Session.get(params[:session])
    redirect '/login' unless session
    @admin = session.admin
  end

  get '/login' do
    haml :login
  end

  post '/login' do
    admin = Admin.get(params[:username])
    if admin && admin.password?(params[:password])
      session = Session.create(:admin => admin)
      redirect "/admin/#{session.token}"
    else
      @flash = 'Incorrect username or password.'
      haml :login
    end
  end

  get '/admin' do
    redirect '/login'
  end

  get '/admin/:session' do
    require_admin
    haml :admin
  end

  post '/admin/:session' do
    require_admin
    if params['new_address']
      Code.rpc.getnewaddress('unallocated')
    end
    if params['new_code']
      amount = params['amount'].to_f
      Code.generate(amount) if amount
    end
    haml :admin
  end

  run! if app_file == $0
end

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
    @title = 'Redeem Bitcards'
    @action = 'Redeem'
    @input = 'Bitcard Code'
    @button = 'success'
    @icon = 'ok'
    haml :index
  end

  post '/redeem' do
    @id = params['bitcard_code']
    @code = Code.get(@id)
    if @code
      @title = 'Send Bitcoins'
      @action = 'Send'
      @input = 'Bitcoin Address'
      @button = 'success'
      @icon = 'share'
      @status = 'success'
      @message = 'Valid code!'
      @prepend = "#{@code.amount} &#3647;"
    else
      @message = 'No such code.'
      @title = 'Redeem Bitcards'
      @action = 'Redeem'
      @input = 'Bitcard Code'
      @status = 'error'
      @button = 'danger'
      @icon = 'ok'
    end
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

require 'sinatra/base'
require 'sinatra/contrib'
require 'sinatra/config_file'

require 'logger'

require 'haml'
require 'json'

require './string.rb'
require './bitcoin_rpc.rb'
require './config.rb'

class Bitcard < Sinatra::Base
  register Sinatra::ConfigFile
  config_file 'config.yml'
  set :port, 8080
  set :environment, $environment
  set :public_folder, 'public'
  set :raise_errors, false
  set :show_exceptions, settings.environment == :development
  enable :logging

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
    code = Code.find_by_challenge(params['challenge'])
    if not code
      logger.info "Bad challenge"
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
      logger.info "Bad secret"
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
    begin
      response = Code.rpc.sendfrom(code.to_s, @address, code.amount)
      logger.info "Code redeemed #{code.to_s} Address #{@address}"
      code.destroy
      @hidden = []
      @input = 'Challenge'
      @message = 'Sent! Enter a new challenge to send more bitcoins.'
    rescue BitcoinRPC::JSONRPCError => e
      @input = 'Secret'
      @message = e.to_s
    end
    haml :index
  end
  
  def require_admin
    @admin = Admin.find_by_session_token(params[:session])
    redirect '/login' unless @admin
  end

  get '/login' do
    haml :login
  end

  post '/login' do
    admin = Admin.find_by_username(params[:username])
    if admin && admin.password?(params[:password])
      token = SecureRandom.uuid
      admin.session_token = token
      admin.save
      logger.info "Admin #{admin.username} Session #{token}"
      redirect "/admin/#{token}"
    else
      logger.info "Admin #{admin.username} Bad password"
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
      logger.info "New receiving address"
    end
    if params['new_code'] and params['amount']
      amount = params['amount'].to_f
      code = Code.generate(amount)
      logger.info "New code #{code.to_s}"
    end
    if params['import']
      Code.all.each do |code|
        code.destroy
        logger.info "Dump code #{code.to_s}"
      end
      Code.import.each do |code|
        logger.info "Import code #{code.to_s}"
      end
    end
    if params['destroy'] and params['code']
      code = Code.find_by_challenge(params['code'])
      code.liquify
      logger.info "Liquify code #{code.to_s}"
    end
    haml :admin
  end

  run! if app_file == $0
end

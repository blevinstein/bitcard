require 'active_record'
require 'logger'

$environment = (ENV['SINATRA_ENV'] || 'development').to_sym

config = YAML.load_file('config.yml')

ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.establish_connection(config['database'])
Dir["#{Dir.pwd}/models/*.rb"].each { |model| require model }
Code.config_rpc(config['bitcoind'])

log = File.open(ENV['LOG_FILE'] || "#{Dir.pwd}/log",'a+')
log.sync = true
STDERR.reopen(log)

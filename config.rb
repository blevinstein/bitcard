require 'data_mapper'
require 'yaml'

# TODO: add config.yml to .gitignore
# TODO: make this load from config file
# TODO: daemonize bitcoind
$environment = :production

DataMapper::Model.raise_on_save_failure = true
DataMapper.setup :default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/db"
Dir['./models/*'].each { |model| require model }
DataMapper.finalize

# TODO: make this work in production environment
#log = File.open(ENV['LOG_FILE'] || "log/#{environment}.log",'a+')
#STDERR.reopen(log)

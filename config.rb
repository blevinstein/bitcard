require 'data_mapper'
require 'yaml'

$environment = (ENV['SINATRA_ENV'] || 'development').to_sym

DataMapper::Model.raise_on_save_failure = true
DataMapper.setup :default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/db"
Dir['./models/*'].each { |model| require model }
DataMapper.finalize

log = File.open(ENV['LOG_FILE'] || "#{Dir.pwd}/log",'a+')
log.sync = true
STDERR.reopen(log)

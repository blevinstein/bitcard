require 'data_mapper'
require 'yaml'

$environment = :development

DataMapper::Model.raise_on_save_failure = true
DataMapper.setup :default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/db"
Dir['./models/*'].each { |model| require model }
DataMapper.finalize

log = File.open("log/#{$environment}.log",'a+')
STDERR.reopen(log)

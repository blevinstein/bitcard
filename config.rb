require 'data_mapper'
require 'yaml'

DataMapper::Model.raise_on_save_failure = true
DataMapper.setup :default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/db"
Dir['./models/*'].each { |model| require model }
DataMapper.finalize

require './config.rb'
require 'pp'

namespace 'db' do
  desc 'Update the database.'
  task :update do
    begin
      DataMapper.auto_upgrade!
      puts 'Updated!'
    rescue Exception => e
      puts e
    end
  end

  desc 'Migrate the database.'
  task :migrate do
    DataMapper.auto_migrate!
    puts 'Migrated!'
  end
end

namespace 'admin' do
  desc "List all admins."
  task :list do
    Admin.each do |admin|
      puts admin.username
    end
  end

  desc "Add an admin account."
  task :add, :username, :password do |t, args|
    begin
      admin = Admin.new(args)
      admin.save
      puts 'Admin account created!'
    rescue Exception => e
      puts admin.errors.inspect unless admin.nil? or admin.valid?
      puts e
    end
  end
end

namespace 'code' do
  desc 'Generate a new code.'
  task :gen, :amount do |t, args|
    code = Code.generate(args[:amount].to_f)
    puts "#{code} generated!"
  end

  desc 'Import codes from bitcoin wallet.'
  task :import do
    Code.import.each do |code|
      puts "#{code.to_s}\t#{code.amount}\u0e3f"
    end
  end

  desc 'List all codes.'
  task :list do
    Code.each do |code|
      puts "#{code.to_s}\t#{code.amount}\u0e3f"
    end
  end

  desc 'Remove a code.'
  task :rm, :code do |t, args|
    puts 'No code given.' and fail unless args[:code]
    challenge = args[:code].split('-')[0]
    code = Code.get(challenge)
    if code
      code.destroy
      puts 'Code removed!'
    else
      puts "Code doesn't exist."
    end
  end

  desc 'Get unallocated balance.'
  task :balance do
    puts Code.unallocated
  end
end

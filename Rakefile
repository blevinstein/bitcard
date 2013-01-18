require './config.rb'

namespace 'db' do
  desc 'Migrate the database.'
  task :migrate do
    DataMapper.auto_upgrade!
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
    admin = Admin.create(args)
    puts 'Admin account created!'
  end
end

namespace 'code' do
  desc 'Add a code to the database.'
  task :add, :redeem_code, :amount do |t, args|
    print args
    Code.create args
  end

  desc 'List all codes.'
  task :list do
    Code.each do |code|
      puts "#{code.redeem_code}\t#{code.amount} BTC"
    end
  end

  desc 'Remove a code.'
  task :rm, :code do |t, args|
    code = Code.get(args[:code])
    if code
      code.destroy
      puts 'Code removed!'
    else
      puts "Code doesn't exist."
    end
  end
end

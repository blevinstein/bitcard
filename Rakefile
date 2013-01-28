require './config.rb'

namespace 'admin' do
  desc "List all admins."
  task :list do
    Admin.all.each do |admin|
      puts admin.username
    end
  end

  desc "Add an admin account."
  task :add, :username, :password do |t, args|
    Admin.create(:username => args[:username], :password => args[:password])
    puts 'Admin account created!'
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

  desc 'Dump all codes.'
  task :dump do
    Code.all.each do |code|
      code.destroy
    end
  end

  desc 'List all codes.'
  task :list do
    Code.all.each do |code|
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

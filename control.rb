# information on daemonizing found here:
# http://www.kalzumeus.com/2010/01/15/deploying-sinatra-on-ubuntu-in-which-i-employ-a-secretary

require 'daemons'

pwd = Dir.pwd
Daemons.run_proc('bitcard') do
  Dir.chdir pwd
  exec "ruby bitcard.rb"
end

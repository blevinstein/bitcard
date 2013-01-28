require 'yaml'
require 'securerandom'

require './bitcoin_rpc.rb'

class Code
  include DataMapper::Resource

  property :challenge, String, :key => true
  property :response,  String
  property :secret,    String
  property :status,    String
  property :amount,    Float

  def to_s
    "#{challenge}-#{response}-#{secret}"
  end

  def liquify
    amount = Code.rpc.getbalance(self.to_s)
    Code.rpc.move(self.to_s, 'unallocated', amount) if amount > 0
    self.destroy
  end

  def self.import
    keys = self.rpc.listaccounts
    keys.map do |key,amount|
      match = /([\d\w]{8})-([\d\w]{8})-([\d\w]{8})/.match(key)
      if match and amount > 0 and not Code.get(match[1])
        Code.create(:challenge => match[1],
                    :response => match[2],
                    :secret => match[3],
                    :amount => amount,
                    :status => 'imported')
      end
    end.reject(&:nil?)
  end

  def self.unallocated
    self.rpc.getbalance('unallocated')
  end

  def self.generate(amount)
    raise 'Amount must be greater than zero.' if amount <= 0
    total = self.unallocated
    raise 'Amount requested not available.' if amount > total
    challenge = SecureRandom.uuid[0,8]
    response = SecureRandom.uuid[0,8]
    secret = SecureRandom.uuid[0,8]
    code = Code.create(:challenge => challenge,
                       :response => response,
                       :secret => secret,
                       :amount => amount,
                       :status => 'generated')
    self.rpc.move('unallocated', code.to_s, amount)
    code
  end

  def self.rpc
    @rpc ||= begin
      config = YAML.load_file('config.yml')['bitcoind']
      BitcoinRPC.new("http://#{config['user']}:#{config['password']}@#{config['host']}:#{config['port']}")
    end
  end
end

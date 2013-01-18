class Code
  include DataMapper::Resource

  property :redeem_code, String, :key => true
  property :amount,      Integer
end

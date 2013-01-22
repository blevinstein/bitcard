class Code
  include DataMapper::Resource

  property :challenge, String, :key => true
  property :response,  String
  property :secret,    String
  property :amount,    Float
end

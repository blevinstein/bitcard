require 'securerandom'

class Session
  include DataMapper::Resource

  property :token,    String, :key => true
  property :accessed, DateTime

  belongs_to :admin

  def self.create(props)
    super(props.merge(:accessed => Time.now,
                      :token => SecureRandom.uuid))
  end

  def self.get(*args)
    session = super(*args)
    session.update(:accessed => Time.now)
    session
  end
end

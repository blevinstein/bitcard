require 'digest/sha1'

class Admin
  include DataMapper::Resource
  
  property :username,          String,  :key => true
  property :password_hash,     String,  :required => true
  property :password_salt,     String,  :required => true

  def password=(new_password)
    self.password_salt = Time.now.to_f.to_s + username
    self.password_hash = Digest::SHA1.hexdigest(new_password + password_salt)
  end

  def password?(given_password)
    Digest::SHA1.hexdigest(given_password + password_salt) == password_hash
  end
end

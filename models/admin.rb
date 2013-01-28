require 'digest/sha1'

class Admin < ActiveRecord::Base
  validates :username, :password_hash, :password_salt, :presence => true
  validates :username, :uniqueness => true
  validates :session_token, :uniqueness => true, :allow_nil => true

  has_many :sessions

  def password=(new_password)
    self.password_salt = Time.now.to_f.to_s + username
    self.password_hash = Digest::SHA1.hexdigest(new_password + password_salt)
  end

  def password?(given_password)
    Digest::SHA1.hexdigest(given_password + password_salt) == password_hash
  end
end

ActiveRecord::Schema.define do
  create_table :admins do |table|
    table.column :username,      :string
    table.column :password_hash, :string
    table.column :password_salt, :string
    table.column :session_token, :string
  end
  #add_index :admins, :username, :unique
end unless Admin.table_exists?

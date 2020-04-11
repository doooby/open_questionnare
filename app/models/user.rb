require 'bcrypt'
require 'securerandom'

class User < ApplicationRecord

  belongs_to :project

  validates :login, presence: true, uniqueness: { scope: :project }, length: { minimum: 5 }
  validates_presence_of :name
  validate :validate_password

  attr_accessor :first_authn_ever

  def password= value
    write_attribute :password, nil

    if valid_password? value
      write_attribute :password, BCrypt::Password.create(value)
    end
  end

  def password? value
    encrypted = password.presence || false
    ::BCrypt::Password.new(encrypted) == value
  end

  def new_token!
    token = SecureRandom.uuid
    tokens.push token
    self.tokens = tokens[-5..-1] if tokens.length > 5
    save!
    token
  end

  def discard_token! token
    tokens.delete token
    save!
  end

  private

  def validate_password
    errors.add :password, :invalid unless password
  end

  def valid_password? value
    return false if value.blank? || value.length < 6

    [/\d/, /[a-z]/, /[A-Z]/].
        map{|type| value.index type}.
        compact.
        uniq.
        length == 3
  end

end

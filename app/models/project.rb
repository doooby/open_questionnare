class Project < ApplicationRecord

  validates :label, presence: true, uniqueness: true,
      length: { minimum: 3, maximum: 10 }, format: { with: /\A[\w\d.\-:]+\z/ }

  has_many :users

end

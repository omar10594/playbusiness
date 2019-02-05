class User < ApplicationRecord
  has_many :investments
  devise :database_authenticatable, :registerable, :validatable
end

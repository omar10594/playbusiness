class Investment < ApplicationRecord
  belongs_to :startup
  belongs_to :user

  validates :user, presence: true
  validates :startup, presence: true
  validates :amount, presence: true
end

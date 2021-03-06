class Startup < ApplicationRecord
    has_many :investments, dependent: :destroy
    validates :name, presence: true, length: { minimum: 6 }
end

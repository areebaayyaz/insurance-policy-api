class Policy < ApplicationRecord
  validates :policy_number, presence: true
  validates :holder_name, presence: true
end

class PolicyStatusEvent < ApplicationRecord
  belongs_to :policy

  validates :to_status, presence: true
  validates :occurred_at, presence: true

  def readonly?
    persisted?
  end
end

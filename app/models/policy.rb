class Policy < ApplicationRecord
  TRANSITIONS = {
    "pending" => ["active", "cancelled"],
    "active" => ["cancelled", "expired"],
    "cancelled" => [],
    "expired" => []
  }.freeze

  has_many :policy_status_events, -> { order(:occurred_at) }, dependent: :destroy

  validates :policy_number, presence: true
  validates :holder_name, presence: true
  validates :status, inclusion: { in: TRANSITIONS.keys }

  def recompute_status!
    latest_event = policy_status_events.order(:occurred_at).last
    update!(status: latest_event.to_status) if latest_event
  end
end

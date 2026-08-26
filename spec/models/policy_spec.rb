require "rails_helper"

RSpec.describe Policy do
  describe "#recompute_status!" do
    let(:policy) do
      Policy.create!(policy_number: "POL-1", holder_name: "Ada Lovelace", status: "pending")
    end

    it "rebuilds the policy's status from the event with the latest occurred_at, not from insertion order" do
      # Written out of chronological order to prove recompute_status! sorts by
      # occurred_at rather than trusting creation order or the id sequence.
      policy.policy_status_events.create!(
        from_status: "active", to_status: "expired", occurred_at: 2.days.ago
      )
      policy.policy_status_events.create!(
        from_status: "pending", to_status: "active", occurred_at: 3.days.ago
      )

      # Simulate the status column having drifted from the event log.
      policy.update_column(:status, "pending")

      policy.recompute_status!

      expect(policy.status).to eq("expired")
    end

    it "leaves the status untouched when there is no event log to rebuild from" do
      expect { policy.recompute_status! }.not_to change(policy, :status)
    end
  end
end

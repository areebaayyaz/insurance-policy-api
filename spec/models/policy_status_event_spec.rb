require "rails_helper"

RSpec.describe PolicyStatusEvent do
  describe "immutability" do
    let(:policy) do
      Policy.create!(policy_number: "POL-1", holder_name: "Ada Lovelace", status: "pending")
    end

    it "raises when a persisted event is updated, preserving the audit trail" do
      event = policy.policy_status_events.create!(
        from_status: "pending",
        to_status: "active",
        occurred_at: Time.current
      )

      expect(event).to be_readonly

      expect {
        event.update!(to_status: "cancelled")
      }.to raise_error(ActiveRecord::ReadOnlyRecord)

      # The stored record is untouched by the failed update attempt.
      expect(event.reload.to_status).to eq("active")
    end
  end
end

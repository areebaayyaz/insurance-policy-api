require "rails_helper"

RSpec.describe Policies::TransitionStatus do
  let(:policy) do
    Policy.create!(policy_number: "POL-1", holder_name: "Ada Lovelace", status: "pending")
  end

  describe ".call" do
    context "when the transition is allowed" do
      it "creates a PolicyStatusEvent recording the transition and updates the policy's status" do
        expect {
          @result = described_class.call(
            policy: policy,
            to_status: "active",
            reason: "underwriting approved"
          )
        }.to change(PolicyStatusEvent, :count).by(1)

        event = @result.event

        expect(@result.success?).to be(true)
        expect(@result.errors).to eq([])

        # The event is the durable record of what happened...
        expect(event).to be_persisted
        expect(event.policy).to eq(policy)
        expect(event.from_status).to eq("pending")
        expect(event.to_status).to eq("active")
        expect(event.reason).to eq("underwriting approved")

        # ...and the policy's current status is projected from it.
        expect(policy.reload.status).to eq("active")
      end
    end

    context "when the transition is not allowed" do
      let(:policy) do
        # "cancelled" is a terminal state: Policy::TRANSITIONS["cancelled"] == []
        Policy.create!(policy_number: "POL-2", holder_name: "Grace Hopper", status: "cancelled")
      end

      it "rejects the transition and writes no event" do
        expect {
          @result = described_class.call(policy: policy, to_status: "active")
        }.not_to change(PolicyStatusEvent, :count)

        expect(@result.success?).to be(false)
        expect(@result.event).to be_nil
        expect(@result.errors).to contain_exactly(
          "cannot transition from 'cancelled' to 'active'"
        )

        # The policy itself is left untouched.
        expect(policy.reload.status).to eq("cancelled")
      end
    end
  end
end

module Policies
  class TransitionStatus
    Result = Struct.new(:success?, :policy, :event, :errors, keyword_init: true)

    def self.call(...)
      new(...).call
    end

    def initialize(policy:, to_status:, reason: nil, occurred_at: Time.current)
      @policy = policy
      @to_status = to_status.to_s
      @reason = reason
      @occurred_at = occurred_at
    end

    def call
      event = nil
      error = nil

      @policy.with_lock do
        allowed_targets = Policy::TRANSITIONS.fetch(@policy.status, [])

        unless allowed_targets.include?(@to_status)
          error = "cannot transition from '#{@policy.status}' to '#{@to_status}'"
          raise ActiveRecord::Rollback
        end

        event = @policy.policy_status_events.create!(
          from_status: @policy.status,
          to_status: @to_status,
          reason: @reason,
          occurred_at: @occurred_at
        )
        @policy.update!(status: @to_status)
      end

      if event
        Result.new(success?: true, policy: @policy, event: event, errors: [])
      else
        Result.new(success?: false, policy: @policy, event: nil, errors: [error])
      end
    end
  end
end

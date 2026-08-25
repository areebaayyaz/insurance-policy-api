class PoliciesController < ApplicationController
  before_action :set_policy, only: [:activate, :cancel]

  def create
    policy = Policy.new(policy_params)

    if policy.save
      render json: policy, status: :created
    else
      render json: { errors: policy.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def activate
    transition_to("active")
  end

  def cancel
    transition_to("cancelled")
  end

  private

  def set_policy
    @policy = Policy.find(params[:id])
  end

  def transition_to(status)
    result = Policies::TransitionStatus.call(policy: @policy, to_status: status, reason: params[:reason])

    if result.success?
      render json: @policy, status: :ok
    else
      render json: { errors: result.errors }, status: :unprocessable_entity
    end
  end

  def policy_params
    params.expect(policy: [:policy_number, :holder_name, :status, :start_date, :end_date])
  end
end

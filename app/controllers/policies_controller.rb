class PoliciesController < ApplicationController
  def create
    policy = Policy.new(policy_params)

    if policy.save
      render json: policy, status: :created
    else
      render json: { errors: policy.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def policy_params
    params.expect(policy: [:policy_number, :holder_name, :status, :start_date, :end_date])
  end
end

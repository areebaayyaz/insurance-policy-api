class PolicyStatusEventsController < ApplicationController
  def index
    policy = Policy.find(params[:policy_id])
    render json: policy.policy_status_events.order(:occurred_at), status: :ok
  end
end

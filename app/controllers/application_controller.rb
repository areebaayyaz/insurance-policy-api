class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: { errors: [exception.message] }, status: :not_found
  end
end

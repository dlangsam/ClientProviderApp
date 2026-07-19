class ApplicationController < ActionController::API
  rescue_from Kaminari::ZeroPerPageOperation do
    render json: { error: 'per_page must be greater than 0' }, status: :bad_request
  end
end

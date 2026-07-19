module Api
  module V1
    class ClientsController < ApplicationController
      include Paginatable

      def show
        client = Client.find(params[:id])
        paginated_assignments = client.provider_assignments.recent.includes(:provider).page(params[:page]).per(params[:per_page])

        render json: {
          id: client.id,
          name: client.name,
          email: client.email,
          providers: paginated_assignments.map do |assignment|
            {
              id: assignment.provider.id,
              name: assignment.provider.name,
              email: assignment.provider.email,
              plan: assignment.plan
            }
          end,
          pagination: pagination_meta(paginated_assignments)
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Client not found' }, status: :not_found
      end
    end
  end
end

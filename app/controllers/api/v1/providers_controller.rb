module Api
  module V1
    class ProvidersController < ApplicationController
      include Paginatable

      def show
        provider = Provider.find(params[:id])
        paginated_assignments = provider.provider_assignments.recent.includes(:client).page(params[:page]).per(params[:per_page])

        render json: {
          id: provider.id,
          name: provider.name,
          email: provider.email,
          clients: paginated_assignments.map do |assignment|
            {
              id: assignment.client.id,
              name: assignment.client.name,
              email: assignment.client.email,
              plan: assignment.plan
            }
          end,
          pagination: pagination_meta(paginated_assignments)
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Provider not found' }, status: :not_found
      end
    end
  end
end

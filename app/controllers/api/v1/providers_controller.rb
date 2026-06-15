module Api
  module V1
    class ProvidersController < ApplicationController
      include Paginatable

      def show
        provider = Provider.includes(provider_assignments: :client).find(params[:id])
        paginated_assignments = paginate_array(provider.provider_assignments.to_a)

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
          pagination: pagination_meta_for_array(provider.provider_assignments.to_a)
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Provider not found' }, status: :not_found
      end
    end
  end
end

module Api
  module V1
    class ProvidersController < ApplicationController
      include Paginatable

      def show
        provider = Provider.includes(:clients, :provider_assignments).find(params[:id])
        paginated_clients = paginate_array(provider.clients.to_a)

        render json: {
          id: provider.id,
          name: provider.name,
          email: provider.email,
          clients: paginated_clients.map do |client|
            assignment = provider.provider_assignments.find_by(client: client)
            {
              id: client.id,
              name: client.name,
              email: client.email,
              plan: assignment.plan
            }
          end,
          pagination: pagination_meta_for_array(provider.clients.to_a)
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Provider not found' }, status: :not_found
      end
    end
  end
end

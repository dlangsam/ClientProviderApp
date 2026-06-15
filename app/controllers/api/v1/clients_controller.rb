module Api
  module V1
    class ClientsController < ApplicationController
      include Paginatable

      def show
        client = Client.includes(:providers, :provider_assignments).find(params[:id])
        paginated_providers = paginate_array(client.providers.to_a)

        render json: {
          id: client.id,
          name: client.name,
          email: client.email,
          providers: paginated_providers.map do |provider|
            assignment = client.provider_assignments.find_by(provider: provider)
            {
              id: provider.id,
              name: provider.name,
              email: provider.email,
              plan: assignment.plan
            }
          end,
          pagination: pagination_meta_for_array(client.providers.to_a)
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Client not found' }, status: :not_found
      end
    end
  end
end

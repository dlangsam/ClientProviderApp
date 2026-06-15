module Api
  module V1
    class ClientsController < ApplicationController
      include Paginatable

      def show
        client = Client.includes(provider_assignments: :provider).find(params[:id])
        paginated_assignments = paginate_array(client.provider_assignments.to_a)

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
          pagination: pagination_meta_for_array(client.provider_assignments.to_a)
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Client not found' }, status: :not_found
      end
    end
  end
end

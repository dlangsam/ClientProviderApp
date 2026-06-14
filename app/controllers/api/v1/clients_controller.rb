module Api
  module V1
    class ClientsController < ApplicationController
      def show
        client = Client.includes(:providers, :provider_assignments).find(params[:id])

        render json: {
          id: client.id,
          name: client.name,
          email: client.email,
          providers: client.providers.map do |provider|
            assignment = client.provider_assignments.find_by(provider: provider)
            {
              id: provider.id,
              name: provider.name,
              email: provider.email,
              plan: assignment.plan
            }
          end
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Client not found' }, status: :not_found
      end
    end
  end
end

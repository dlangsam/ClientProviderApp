module Api
  module V1
    class ProvidersController < ApplicationController
      def show
        provider = Provider.includes(:clients, :provider_assignments).find(params[:id])

        render json: {
          id: provider.id,
          name: provider.name,
          email: provider.email,
          clients: provider.clients.map do |client|
            assignment = provider.provider_assignments.find_by(client: client)
            {
              id: client.id,
              name: client.name,
              email: client.email,
              plan: assignment.plan
            }
          end
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Provider not found' }, status: :not_found
      end
    end
  end
end

module Api
  module V1
    class NotesController < ApplicationController
      # POST /api/v1/clients/:client_id/notes
      def create
        client = Client.find(params[:client_id])
        note = client.notes.build(note_params)

        if note.save
          render json: {
            id: note.id,
            content: note.content,
            created_at: note.created_at,
            client_id: note.client_id
          }, status: :created
        else
          render json: { errors: note.errors.full_messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Client not found' }, status: :not_found
      end

      # GET /api/v1/clients/:client_id/notes
      def index_for_client
        client = Client.find(params[:client_id])
        notes = client.notes.sorted_by_date

        render json: notes.map { |note|
          {
            id: note.id,
            content: note.content,
            created_at: note.created_at,
            client_id: note.client_id
          }
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Client not found' }, status: :not_found
      end

      # GET /api/v1/providers/:id/notes
      def index_for_provider
        provider = Provider.includes(clients: :notes).find(params[:id])
        notes = provider.clients.flat_map(&:notes).sort_by(&:created_at).reverse

        render json: notes.map { |note|
          {
            id: note.id,
            content: note.content,
            created_at: note.created_at,
            client_id: note.client_id,
            client_name: note.client.name
          }
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Provider not found' }, status: :not_found
      end

      private

      def note_params
        params.require(:note).permit(:content)
      end
    end
  end
end

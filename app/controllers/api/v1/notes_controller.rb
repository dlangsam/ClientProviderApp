module Api
  module V1
    class NotesController < ApplicationController
      include Paginatable
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
        render json: { error: "Client not found" }, status: :not_found
      end

      # GET /api/v1/clients/:client_id/notes
      def index_for_client
        client = Client.find(params[:client_id])
        paginated_notes = client.notes.sorted_by_date.page(params[:page]).per(params[:per_page])

        render json: {
          notes: paginated_notes.map { |note|
            {
              id: note.id,
              content: note.content,
              created_at: note.created_at,
              client_id: note.client_id
            }
          },
          pagination: pagination_meta(paginated_notes)
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Client not found" }, status: :not_found
      end

      # GET /api/v1/providers/:id/notes
      def index_for_provider
        provider = Provider.find(params[:id])
        paginated_notes = Note.joins(client: { provider_assignments: :provider })
                              .where(provider_assignments: { provider_id: provider.id })
                              .includes(:client)
                              .order(created_at: :desc)
                              .page(params[:page]).per(params[:per_page])

        render json: {
          notes: paginated_notes.map { |note|
            {
              id: note.id,
              content: note.content,
              created_at: note.created_at,
              client_id: note.client_id,
              client_name: note.client.name
            }
          },
          pagination: pagination_meta(paginated_notes)
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Provider not found" }, status: :not_found
      end

      private

      def note_params
        params.require(:note).permit(:content)
      end
    end
  end
end

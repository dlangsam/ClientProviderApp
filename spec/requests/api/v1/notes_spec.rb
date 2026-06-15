require 'rails_helper'

RSpec.describe "Api::V1::Notes", type: :request do
  describe "POST /api/v1/clients/:client_id/notes" do
    let(:client) { create(:client) }

    context "with valid parameters" do
      let(:valid_params) do
        { note: { content: "This is a test note" } }
      end

      it "creates a new note" do
        expect {
          post "/api/v1/clients/#{client.id}/notes", params: valid_params
        }.to change(Note, :count).by(1)
      end

      it "returns the created note" do
        post "/api/v1/clients/#{client.id}/notes", params: valid_params

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['content']).to eq("This is a test note")
        expect(json['client_id']).to eq(client.id)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        { note: { content: "" } }
      end

      it "does not create a note" do
        expect {
          post "/api/v1/clients/#{client.id}/notes", params: invalid_params
        }.not_to change(Note, :count)
      end

      it "returns validation errors" do
        post "/api/v1/clients/#{client.id}/notes", params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to be_present
      end
    end

    context "with non-existent client" do
      it "returns 404" do
        post "/api/v1/clients/99999/notes", params: { note: { content: "test" } }

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Client not found')
      end
    end
  end

  describe "GET /api/v1/clients/:client_id/notes" do
    let(:client) { create(:client) }

    before do
      # Create notes with different timestamps
      @note1 = create(:note, client: client, content: "First note", created_at: 3.days.ago)
      @note2 = create(:note, client: client, content: "Second note", created_at: 2.days.ago)
      @note3 = create(:note, client: client, content: "Third note", created_at: 1.day.ago)
    end

    it "returns all notes for the client" do
      get "/api/v1/clients/#{client.id}/notes"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(3)
    end

    it "returns notes sorted by date (newest first)" do
      get "/api/v1/clients/#{client.id}/notes"

      json = JSON.parse(response.body)
      expect(json[0]['content']).to eq("Third note")
      expect(json[1]['content']).to eq("Second note")
      expect(json[2]['content']).to eq("First note")
    end

    context "with non-existent client" do
      it "returns 404" do
        get "/api/v1/clients/99999/notes"

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Client not found')
      end
    end
  end

  describe "GET /api/v1/providers/:id/notes" do
    let(:provider) { create(:provider) }
    let(:client1) { create(:client) }
    let(:client2) { create(:client) }

    before do
      # Assign clients to provider
      create(:provider_assignment, provider: provider, client: client1)
      create(:provider_assignment, provider: provider, client: client2)

      # Create notes for both clients
      @note1 = create(:note, client: client1, content: "Client 1 note", created_at: 3.days.ago)
      @note2 = create(:note, client: client2, content: "Client 2 note", created_at: 2.days.ago)
      @note3 = create(:note, client: client1, content: "Client 1 newer note", created_at: 1.day.ago)

      # Create a note for a different client (not assigned to this provider)
      other_client = create(:client)
      create(:note, client: other_client, content: "Other client note")
    end

    it "returns all notes from provider's clients" do
      get "/api/v1/providers/#{provider.id}/notes"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(3)
    end

    it "returns notes sorted by date (newest first)" do
      get "/api/v1/providers/#{provider.id}/notes"

      json = JSON.parse(response.body)
      expect(json[0]['content']).to eq("Client 1 newer note")
      expect(json[1]['content']).to eq("Client 2 note")
      expect(json[2]['content']).to eq("Client 1 note")
    end

    it "includes client information" do
      get "/api/v1/providers/#{provider.id}/notes"

      json = JSON.parse(response.body)
      expect(json[0]['client_id']).to be_present
      expect(json[0]['client_name']).to be_present
    end

    it "does not include notes from clients not assigned to the provider" do
      get "/api/v1/providers/#{provider.id}/notes"

      json = JSON.parse(response.body)
      contents = json.map { |n| n['content'] }
      expect(contents).not_to include("Other client note")
    end

    context "with non-existent provider" do
      it "returns 404" do
        get "/api/v1/providers/99999/notes"

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Provider not found')
      end
    end
  end
end

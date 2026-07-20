require 'rails_helper'

RSpec.describe "Api::V1::Clients", type: :request do
  describe "GET /api/v1/clients/:id" do
    let(:client) { create(:client) }

    context "with no providers" do
      it "returns client with empty providers array" do
        get "/api/v1/clients/#{client.id}"
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['id']).to eq(client.id)
        expect(json['name']).to eq(client.name)
        expect(json['email']).to eq(client.email)
        expect(json['providers']).to eq([])
        expect(json['pagination']).to be_present
      end
    end

    context "with providers" do
      let!(:provider1) { create(:provider) }
      let!(:provider2) { create(:provider) }
      let!(:assignment1) { create(:provider_assignment, provider: provider1, client: client, plan: :basic) }
      let!(:assignment2) { create(:provider_assignment, provider: provider2, client: client, plan: :premium) }

      it "returns client with paginated providers" do
        get "/api/v1/clients/#{client.id}"
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['providers'].length).to eq(2)
        expect(json['pagination']['total_count']).to eq(2)
      end

      it "includes plan from provider_assignment" do
        get "/api/v1/clients/#{client.id}"
        json = JSON.parse(response.body)

        plans = json['providers'].map { |p| p['plan'] }
        expect(plans).to match_array([ 'basic', 'premium' ])
      end

      it "includes provider details" do
        get "/api/v1/clients/#{client.id}"
        json = JSON.parse(response.body)
        provider_data = json['providers'].first

        expect(provider_data).to have_key('id')
        expect(provider_data).to have_key('name')
        expect(provider_data).to have_key('email')
        expect(provider_data).to have_key('plan')
      end

      it "orders providers by most recent assignment first" do
        get "/api/v1/clients/#{client.id}"
        json = JSON.parse(response.body)

        # Most recent assignment should be first
        expect(json['providers'].first['id']).to eq(provider2.id)
        expect(json['providers'].last['id']).to eq(provider1.id)
      end
    end

    context "pagination" do
      let!(:providers) { create_list(:provider, 15) }

      before do
        providers.each do |provider|
          create(:provider_assignment, provider: provider, client: client, plan: :premium)
        end
      end

      it "returns default 10 providers per page" do
        get "/api/v1/clients/#{client.id}"
        json = JSON.parse(response.body)

        expect(json['providers'].length).to eq(10)
        expect(json['pagination']['per_page']).to eq(10)
        expect(json['pagination']['current_page']).to eq(1)
        expect(json['pagination']['total_pages']).to eq(2)
        expect(json['pagination']['total_count']).to eq(15)
      end

      it "supports custom per_page parameter" do
        get "/api/v1/clients/#{client.id}?per_page=5"
        json = JSON.parse(response.body)

        expect(json['providers'].length).to eq(5)
        expect(json['pagination']['per_page']).to eq(5)
        expect(json['pagination']['total_pages']).to eq(3)
      end

      it "supports page parameter" do
        get "/api/v1/clients/#{client.id}?page=2"
        json = JSON.parse(response.body)

        expect(json['providers'].length).to eq(5)
        expect(json['pagination']['current_page']).to eq(2)
      end

      it "returns empty array for page beyond total_pages" do
        get "/api/v1/clients/#{client.id}?page=99"
        json = JSON.parse(response.body)

        expect(json['providers']).to eq([])
        expect(json['pagination']['current_page']).to eq(99)
      end
    end

    context "with non-existent client" do
      it "returns 404" do
        get "/api/v1/clients/99999"
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Client not found')
      end
    end
  end
end

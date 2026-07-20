require 'rails_helper'

RSpec.describe "Api::V1::Providers", type: :request do
  describe "GET /api/v1/providers/:id" do
    let(:provider) { create(:provider) }

    context "with no clients" do
      it "returns provider with empty clients array" do
        get "/api/v1/providers/#{provider.id}"
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['id']).to eq(provider.id)
        expect(json['name']).to eq(provider.name)
        expect(json['email']).to eq(provider.email)
        expect(json['clients']).to eq([])
        expect(json['pagination']).to be_present
      end
    end

    context "with clients" do
      let!(:client1) { create(:client) }
      let!(:client2) { create(:client) }
      let!(:assignment1) { create(:provider_assignment, provider: provider, client: client1, plan: :basic) }
      let!(:assignment2) { create(:provider_assignment, provider: provider, client: client2, plan: :premium) }

      it "returns provider with paginated clients" do
        get "/api/v1/providers/#{provider.id}"
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['clients'].length).to eq(2)
        expect(json['pagination']['total_count']).to eq(2)
      end

      it "includes plan from provider_assignment" do
        get "/api/v1/providers/#{provider.id}"
        json = JSON.parse(response.body)

        plans = json['clients'].map { |c| c['plan'] }
        expect(plans).to match_array([ 'basic', 'premium' ])
      end

      it "includes client details" do
        get "/api/v1/providers/#{provider.id}"
        json = JSON.parse(response.body)
        client_data = json['clients'].first

        expect(client_data).to have_key('id')
        expect(client_data).to have_key('name')
        expect(client_data).to have_key('email')
        expect(client_data).to have_key('plan')
      end

      it "orders clients by most recent assignment first" do
        get "/api/v1/providers/#{provider.id}"
        json = JSON.parse(response.body)

        # Most recent assignment should be first
        expect(json['clients'].first['id']).to eq(client2.id)
        expect(json['clients'].last['id']).to eq(client1.id)
      end
    end

    context "pagination" do
      let!(:clients) { create_list(:client, 15) }

      before do
        clients.each do |client|
          create(:provider_assignment, provider: provider, client: client, plan: :basic)
        end
      end

      it "returns default 10 clients per page" do
        get "/api/v1/providers/#{provider.id}"
        json = JSON.parse(response.body)

        expect(json['clients'].length).to eq(10)
        expect(json['pagination']['per_page']).to eq(10)
        expect(json['pagination']['current_page']).to eq(1)
        expect(json['pagination']['total_pages']).to eq(2)
        expect(json['pagination']['total_count']).to eq(15)
      end

      it "supports custom per_page parameter" do
        get "/api/v1/providers/#{provider.id}?per_page=5"
        json = JSON.parse(response.body)

        expect(json['clients'].length).to eq(5)
        expect(json['pagination']['per_page']).to eq(5)
        expect(json['pagination']['total_pages']).to eq(3)
      end

      it "supports page parameter" do
        get "/api/v1/providers/#{provider.id}?page=2"
        json = JSON.parse(response.body)

        expect(json['clients'].length).to eq(5)
        expect(json['pagination']['current_page']).to eq(2)
      end

      it "returns empty array for page beyond total_pages" do
        get "/api/v1/providers/#{provider.id}?page=99"
        json = JSON.parse(response.body)

        expect(json['clients']).to eq([])
        expect(json['pagination']['current_page']).to eq(99)
      end
    end

    context "with non-existent provider" do
      it "returns 404" do
        get "/api/v1/providers/99999"
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Provider not found')
      end
    end
  end
end

require 'rails_helper'

RSpec.describe "Pagination Edge Cases", type: :request do
  let(:provider) { create(:provider) }
  let(:client) { create(:client) }

  before do
    create(:provider_assignment, provider: provider, client: client)
    create_list(:note, 5, client: client)
  end

  describe "per_page parameter validation" do
    it "handles per_page=0 gracefully" do
      get "/api/v1/clients/#{client.id}/notes?per_page=0"
      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('per_page must be greater than 0')
    end

    it "enforces max_per_page limit of 100" do
      get "/api/v1/clients/#{client.id}/notes?per_page=150"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      # Kaminari should cap at 100
      expect(json['pagination']['per_page']).to eq(100)
    end

    it "handles negative per_page values" do
      get "/api/v1/clients/#{client.id}/notes?per_page=-5"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      # Kaminari defaults to 10 for invalid values
      expect(json['pagination']['per_page']).to eq(10)
    end

    it "handles non-numeric per_page values" do
      get "/api/v1/clients/#{client.id}/notes?per_page=abc"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['pagination']['per_page']).to eq(10)
    end

    it "handles extremely large per_page values" do
      get "/api/v1/clients/#{client.id}/notes?per_page=999999999999"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['pagination']['per_page']).to eq(100)
    end
  end

  describe "page parameter validation" do
    it "handles page=0" do
      get "/api/v1/clients/#{client.id}/notes?page=0"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      # Kaminari treats 0 as 1
      expect(json['pagination']['current_page']).to eq(1)
    end

    it "handles negative page values" do
      get "/api/v1/clients/#{client.id}/notes?page=-1"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['pagination']['current_page']).to eq(1)
    end

    it "handles non-numeric page values" do
      get "/api/v1/clients/#{client.id}/notes?page=xyz"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['pagination']['current_page']).to eq(1)
    end

    it "handles extremely large page values" do
      get "/api/v1/clients/#{client.id}/notes?page=999999"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['notes']).to eq([]) # No results on out-of-range page
      expect(json['pagination']['current_page']).to eq(999999)
    end
  end

  describe "SQL injection attempts" do
    it "sanitizes malicious page parameter" do
      expect {
        get "/api/v1/clients/#{client.id}/notes?page=1'; DROP TABLE notes;--"
      }.not_to raise_error
      expect(Note.count).to eq(5) # Table should still exist
    end

    it "sanitizes malicious per_page parameter" do
      expect {
        get "/api/v1/clients/#{client.id}/notes?per_page=10 OR 1=1"
      }.not_to raise_error
      expect(response).to have_http_status(:ok)
    end
  end

  describe "XSS attempts in pagination params" do
    it "handles script tags in page parameter" do
      get "/api/v1/clients/#{client.id}/notes?page=<script>alert(1)</script>"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['pagination']['current_page']).to eq(1)
    end
  end
end

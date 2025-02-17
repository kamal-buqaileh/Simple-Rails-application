# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "API V1 Partners", type: :request do
  let!(:service)    { create(:service, name: "Flooring") }
  let!(:material)   { create(:material, name: "Wood") }
  let!(:partner) do
    # Use fixed coordinates for determinism
    create(
      :partner,
      rating: 4.5,
      operating_radius: 5,
      geog: "SRID=4326;POINT(13.35 52.45)"
    )
  end

  before do
    # Associate the partner with service and material
    create(:partner_service, partner: partner, service: service)
    create(:service_material, service: service, material: material)
  end

  describe "GET /api/v1/partners" do
    context "when matching partners" do
      it "returns a list of partners" do
        get "/api/v1/partners", params: { lat: 52.45, lng: 13.35, service_id: service.id, material_id: material.id }
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        # Expect the top-level key to be "data" per JSON:API conventions
        expect(json).to have_key("data")
        expect(json["data"]).to be_an(Array)
        # Check that at least one partner is returned with the expected attributes
        expect(json["data"].first["attributes"]).to include("name", "rating", "operating_radius")
      end
    end
  end

  describe "GET /api/v1/partners/:id" do
    context "when the partner exists" do
      it "returns partner details with associations" do
        get "/api/v1/partners/#{partner.id}"
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to have_key("data")
        data = json["data"]
        expect(data["attributes"]).to include("name", "rating", "operating_radius")
        expect(data).to have_key("relationships")
      end
    end

    context "when the partner does not exist" do
      it "returns a 404 not found" do
        get "/api/v1/partners/0"
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json).to have_key("error")
        expect(json["error"]).to eq("Partner not found")
      end
    end
  end
end

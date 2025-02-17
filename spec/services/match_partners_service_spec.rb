# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MatchPartnersService, type: :service do
  let!(:service)   { create(:service, name: "Flooring") }
  let!(:material)  { create(:material, name: "Wood") }

  # Create deterministic partners by overriding geog with fixed coordinates.
  let!(:partner1) do
    create(
      :partner,
      rating: 4.5,
      operating_radius: 5,
      geog: "SRID=4326;POINT(13.35 52.45)"  # Exactly at these coordinates
    )
  end

  let!(:partner2) do
    create(
      :partner,
      rating: 3.0,
      operating_radius: 2,
      geog: "SRID=4326;POINT(13.50 52.50)"  # Out of range
    )
  end

  # Create associations so that the partners are linked to the service and material.
  before do
    create(:partner_service, partner: partner1, service: service)
    create(:partner_service, partner: partner2, service: service)
    create(:service_material, service: service, material: material)
  end

  describe "#call" do
    context "when matching partners successfully" do
      it "returns partners that match the given criteria" do
        # Use coordinates that exactly match partner1.
        service_obj = MatchPartnersService.new(
          latitude: 52.45,
          longitude: 13.35,
          service_id: service.id,
          material_id: material.id,
          last_id: 0,
          limit: 10
        )
        result = service_obj.call
        expect(result).not_to be_empty
        # We expect partner1 to match since its geog exactly matches.
        expect(result).to include(partner1)
      end

      it "returns an empty array if no partner matches" do
        service_obj = MatchPartnersService.new(
          latitude: 0,
          longitude: 0,
          service_id: service.id,
          material_id: material.id,
          last_id: 0,
          limit: 10
        )
        result = service_obj.call
        expect(result).to eq([])
      end
    end

    context "when an error occurs during matching" do
      before do
        # Simulate an error by stubbing a method in the query chain.
        allow(Partner).to receive(:select).and_raise(StandardError.new("Test error"))
      end

      it "logs the error and returns an empty array" do
        # We use a matcher to check that the log contains our expected JSON context.
        expect(Rails.logger).to receive(:error).with(a_string_including(
          '"context":"PartnerQueries"',
          '"error":"Test error"',
          "\"service_id\":#{service.id}",
          "\"material_id\":#{material.id}"
        ))
        service_obj = MatchPartnersService.new(
          latitude: 52.45,
          longitude: 13.35,
          service_id: service.id,
          material_id: material.id,
          last_id: 0,
          limit: 10
        )
        result = service_obj.call
        expect(result).to eq([])
      end
    end
  end
end

# spec/queries/partner_queries_spec.rb
require 'rails_helper'

RSpec.describe PartnerQueries, type: :model do
  describe '.partner_details' do
    let!(:service) { create(:service) }
    let!(:material) { create(:material) }
    let!(:partner) { create(:partner) }
    let!(:partner_service) { create(:partner_service, partner: partner, service: service) }
    let!(:service_material) { create(:service_material, service: service, material: material) }

    context 'when fetching partner details successfully' do
      it 'returns the partner with its associations preloaded' do
        result = PartnerQueries.partner_details(partner.id)
        expect(result).to eq(partner)
        # Verify that the associations (services) are loaded
        expect(result.association(:services)).to be_loaded
      end
    end

    context 'when the partner is not found' do
      it 'returns nil' do
        result = PartnerQueries.partner_details(999_999)
        expect(result).to be_nil
      end
    end

    context 'when an error occurs during fetching' do
      before do
        allow(Partner).to receive(:includes).and_raise(StandardError.new("Test error"))
      end

      it 'logs the error and returns nil' do
        expect(Rails.logger).to receive(:error).with(a_string_including(
          '"context":"PartnerQueries"',
          '"error":"Test error"',
          "\"partner_id\":#{partner.id}"
        ))
        result = PartnerQueries.partner_details(partner.id)
        expect(result).to be_nil
      end
    end
  end

  describe '.match_partners' do
    # Create a couple of services and materials to simulate a realistic scenario.
    let!(:service) { create(:service, name: "Flooring") }
    let!(:material) { create(:material, name: "Wood") }

    # Create multiple partners with random geog values (using the factory's raw SQL expression).
    let!(:partner1) { create(:partner, rating: 4.5, operating_radius: 5) }
    let!(:partner2) { create(:partner, rating: 3.0, operating_radius: 2) }

    # Associate the partners with the service.
    let!(:partner_service1) { create(:partner_service, partner: partner1, service: service) }
    let!(:partner_service2) { create(:partner_service, partner: partner2, service: service) }

    # Link the service with the material.
    let!(:service_material) { create(:service_material, service: service, material: material) }

    context 'when matching partners successfully' do
      it 'returns partners that match the given criteria' do
        # Coordinates chosen so that at least one partner is within range.
        result = PartnerQueries.match_partners(partner1.geog.lat, partner1.geog.lon, service.id, material.id)
        expect(result).not_to be_empty
        # Expect that partner1 (with a higher rating and a larger operating radius) is returned.
        expect(result).to include(partner1)
        # Depending on the random geog values, partner2 might be out-of-range.
      end

      it 'returns an empty array if no partner matches' do
        # Coordinates far away so that no partner qualifies.
        result = PartnerQueries.match_partners(0, 0, service.id, material.id)
        expect(result).to eq([])
      end
    end

    context 'when an error occurs during matching' do
      before do
        # Force an error by stubbing a method in the query chain.
        allow(Partner).to receive(:select).and_raise(StandardError.new("Test error"))
      end

      it 'logs the error and returns an empty array' do
        expect(Rails.logger).to receive(:error).with(a_string_including(
          '"context":"PartnerQueries"',
          '"error":"Test error"',
          "\"service_id\":#{service.id}",
          "\"material_id\":#{material.id}"
        ))
        result = PartnerQueries.match_partners(0, 0, service.id, material.id)
        expect(result).to eq([])
      end
    end
  end
end

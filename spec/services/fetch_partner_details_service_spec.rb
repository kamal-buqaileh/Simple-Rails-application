# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FetchPartnerDetailsService, type: :service do
  let!(:service)   { create(:service, name: "Flooring") }
  let!(:material)  { create(:material, name: "Wood") }
  let!(:partner)   { create(:partner) }

  # Associate the partner with the service and material.
  before do
    create(:partner_service, partner: partner, service: service)
    create(:service_material, service: service, material: material)
  end

  describe "#call" do
    context "when partner details are fetched successfully" do
      it "returns the partner with preloaded associations" do
        service_obj = FetchPartnerDetailsService.new(partner.id)
        result = service_obj.call
        expect(result).to eq(partner)
        # Verify that associated services are preloaded.
        expect(result.association(:services)).to be_loaded
      end
    end

    context "when no partner is found" do
      it "returns nil" do
        service_obj = FetchPartnerDetailsService.new(0)
        result = service_obj.call
        expect(result).to be_nil
      end
    end

    context "when an error occurs while fetching partner details" do
      before do
        # Force an error by stubbing the includes method.
        allow(Partner).to receive(:includes).and_raise(StandardError.new("Test error"))
      end

      it "logs the error and returns nil" do
        expect(Rails.logger).to receive(:error).with(a_string_including(
          '"context":"PartnerQueries"',
          '"error":"Test error"',
          '"partner_id":'  # We'll check that partner_id appears in the JSON log.
        ))
        service_obj = FetchPartnerDetailsService.new(partner.id)
        result = service_obj.call
        expect(result).to be_nil
      end
    end
  end
end

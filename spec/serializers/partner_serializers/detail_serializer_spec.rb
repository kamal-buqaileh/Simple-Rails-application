# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PartnerSerializers::DetailSerializer, type: :serializer do
  let!(:service) { create(:service, name: "Flooring") }
  let!(:material) { create(:material, name: "Wood") }
  let(:partner) do
    create(
      :partner,
      rating: 4.5,
      operating_radius: 5,
      geog: "SRID=4326;POINT(13.35 52.45)"
    )
  end

  before do
    create(:partner_service, partner: partner, service: service)
    create(:service_material, service: service, material: material)
  end

  subject do
    described_class.new(partner, { include: [ :services, :materials ] }).serializable_hash
  end

  it "includes the expected attributes" do
    expect(subject[:data][:attributes]).to include(:name, :rating, :operating_radius)
  end

  it "includes relationships for services and materials" do
    expect(subject[:data]).to have_key(:relationships)
    expect(subject[:data][:relationships]).to have_key(:services)
    expect(subject[:data][:relationships]).to have_key(:materials)
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServiceSerializer, type: :serializer do
  let(:material) { create(:material, name: "Wood") }
  let(:service) { create(:service, name: "Flooring") }

  before do
    service.materials << material
  end

  subject { ServiceSerializer.new(service).serializable_hash }

  it "serializes the service with id and name" do
    data = subject[:data]
    expect(data[:attributes]).to include(:name)
    expect(data[:id]).to eq(service.id.to_s)
    expect(data[:type]).to eq(:service)
  end

  it "serializes associated materials" do
    relationships = subject[:data][:relationships]
    expect(relationships).to have_key(:materials)
    material_data = relationships[:materials][:data].first
    expect(material_data[:id]).to eq(material.id.to_s)
    expect(material_data[:type]).to eq(:material)
  end
end

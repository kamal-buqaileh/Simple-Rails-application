# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MaterialSerializer, type: :serializer do
  let(:material) { create(:material, name: "Wood") }

  subject { MaterialSerializer.new(material).serializable_hash }

  it "serializes the material with id and name" do
    data = subject[:data]
    expect(data[:attributes]).to include(:name)
    expect(data[:id]).to eq(material.id.to_s)
    expect(data[:type]).to eq(:material)
  end
end

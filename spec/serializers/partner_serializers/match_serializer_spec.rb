# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PartnerSerializers::MatchSerializer, type: :serializer do
  let(:partner) do
    create(
      :partner,
      rating: 4.5,
      operating_radius: 5,
      geog: "SRID=4326;POINT(13.35 52.45)"
    )
  end

  subject { described_class.new(partner).serializable_hash }

  it "includes the expected attributes" do
    expect(subject[:data][:attributes]).to include(:name, :rating, :operating_radius)
  end

  it "does not include services or materials by default" do
    expect(subject[:data]).not_to have_key(:relationships)
  end
end

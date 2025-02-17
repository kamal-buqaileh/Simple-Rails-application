module PartnerSerializers
  class MatchSerializer
    include JSONAPI::Serializer
    set_type :partner
    attributes :id, :name, :rating, :operating_radius

    attribute :location do |object|
      { lat: object.geog.latitude, lng: object.geog.longitude }
    rescue
      {}
    end

    attribute :distance do |object|
      object[:distance] || object.attributes["distance"]
    end
  end
end

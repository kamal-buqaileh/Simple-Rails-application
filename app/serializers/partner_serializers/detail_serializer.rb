module PartnerSerializers
  class DetailSerializer
    include JSONAPI::Serializer
    set_type :partner

    attributes :id, :name, :rating, :operating_radius

    has_many :services, serializer: ServiceSerializer, attribute: [ :id, :name ]
    has_many :materials, serializer: MaterialSerializer, fields: [ :id, :name ]

    attribute :location do |object|
      { lat: object.geog.latitude, lng: object.geog.longitude }
    rescue
      {}
    end
  end
end

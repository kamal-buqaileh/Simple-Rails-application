class ServiceSerializer
  include JSONAPI::Serializer
  set_type :service

  attributes :id, :name

  has_many :materials, serializer: MaterialSerializer
end

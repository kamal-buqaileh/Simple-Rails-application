class MaterialSerializer
  include JSONAPI::Serializer
  set_type :material

  attributes :id, :name
end

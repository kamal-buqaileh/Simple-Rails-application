# frozen_string_literal: true

class MatchPartnersService
  attr_reader :latitude, :longitude, :service_id, :material_id, :last_id, :limit

  def initialize(latitude:, longitude:, service_id:, material_id:, last_id: 0, limit: 10)
    @latitude    = latitude
    @longitude   = longitude
    @service_id  = service_id
    @material_id = material_id
    @last_id     = last_id
    @limit       = limit
  end

  def call
    PartnerQueries.match_partners(latitude, longitude, service_id, material_id, last_id, limit)
  rescue StandardError => e
    log_error("MatchPartnersService",
      e,
      { latitude: latitude,
        longitude: longitude,
        service_id: service_id,
        material_id: material_id,
        last_id: last_id,
        limit: limit }
      )
    []
  end
end

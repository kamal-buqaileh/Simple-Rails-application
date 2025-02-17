# frozen_string_literal: true

class PartnerQueries
  include SlidingCache
  # Fetch Partner Details with Services and Materials
  def self.partner_details(partner_id)
    SlidingCache.fetch("partner_details_#{partner_id}") do
      Partner.includes(services: { service_materials: :material })
             .find_by(id: partner_id)
    end
  rescue StandardError => e
    log_error("PartnerQueries", e, { partner_id: partner_id })
    nil
  end

  # Search/Match Partners Based on Customer Location, Service, and Material
  def self.match_partners(latitude, longitude, service_id, material_id, last_id = 0, limit = 10)
    lng = longitude.to_f
    lat = latitude.to_f
    # Build a sanitized SQL snippet for the customer's geography point.
    customer_geog_sql = ActiveRecord::Base.sanitize_sql_array(
      [ "ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography", lng, lat ]
    )
    SlidingCache.fetch("match_partners_#{latitude}_#{longitude}_#{service_id}_#{material_id}_#{last_id}_#{limit}", expiry: 10.minutes) do
      Partner
        .select("partners.*, ST_Distance(geog, #{customer_geog_sql}) AS distance")
        .joins(partner_services: { service: :service_materials })
        .where(partner_services: { service_id: service_id })
        .where(service_materials: { material_id: material_id })
        .where("ST_DWithin(geog, #{customer_geog_sql}, operating_radius * 1000)")
        .where("partners.id > ?", last_id)  # Keyset Pagination
        .order("partners.rating DESC, distance ASC")
        .limit(limit)
    end
  rescue StandardError => e
    log_error("PartnerQueries",
      e,
      { latitude: latitude,
        longitude: longitude,
        service_id: service_id,
        material_id: material_id,
        last_id: last_id,
        limit: limit
      }
    )
    []
  end
end

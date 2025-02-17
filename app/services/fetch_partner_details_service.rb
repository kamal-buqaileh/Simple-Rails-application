# frozen_string_literal: true

class FetchPartnerDetailsService
  attr_reader :partner_id

  def initialize(partner_id)
    @partner_id = partner_id
  end

  def call
    PartnerQueries.partner_details(partner_id)
  rescue StandardError => e
    log_error("FetchPartnerDetailsService", e, { partner_id: partner_id })
    nil
  end
end

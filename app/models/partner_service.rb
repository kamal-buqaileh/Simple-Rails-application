# frozen_string_literal: true

class PartnerService < ApplicationRecord
  belongs_to :partner
  belongs_to :service
end

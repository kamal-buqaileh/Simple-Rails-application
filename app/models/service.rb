# frozen_string_literal: true

class Service < ApplicationRecord
  has_many :partner_services
  has_many :partners, through: :partner_services

  has_many :service_materials
  has_many :materials, through: :service_materials
end

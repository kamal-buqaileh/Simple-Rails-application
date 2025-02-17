# frozen_string_literal: true

class Partner < ApplicationRecord
  has_many :partner_services
  has_many :services, through: :partner_services

  has_many :service_materials, through: :services
  has_many :materials, through: :service_materials
end

# frozen_string_literal: true

class Material < ApplicationRecord
  has_many :service_materials
  has_many :services, through: :service_materials
end

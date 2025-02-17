# frozen_string_literal: true

class ServiceMaterial < ApplicationRecord
  belongs_to :service
  belongs_to :material
end

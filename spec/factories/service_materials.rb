# frozen_string_literal: true

FactoryBot.define do
  factory :service_material do
    association :service
    association :material
  end
end

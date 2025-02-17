# frozen_string_literal: true

FactoryBot.define do
  factory :partner_service do
    association :partner
    association :service
  end
end

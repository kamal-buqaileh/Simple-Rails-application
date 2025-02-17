# frozen_string_literal: true

FactoryBot.define do
  factory :service do
    name { Faker::Commerce.department(max: 1, fixed_amount: true) }
  end
end

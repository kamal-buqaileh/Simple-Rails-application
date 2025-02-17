# spec/factories/partners.rb
FactoryBot.define do
  factory :partner do
    name { Faker::Company.name }
    rating { rand(1.0..5.0).round(1) }
    operating_radius { rand(1.0..20.0).round(2) }
    geog { "SRID=4326;POINT(#{13.3 + rand * 0.2} #{52.4 + rand * 0.2})" }  # Random Berlin coordinates
  end
end

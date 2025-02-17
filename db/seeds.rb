# db/seeds.rb

puts "Seeding database..."

# Create Services
services = [ "flooring", "plumbing", "electrical", "painting", "roofing" ].map do |service_name|
  Service.find_or_create_by!(name: service_name)
end
puts "✅ Created #{services.count} services"

# Create Materials
materials = [ "wood", "tiles", "carpet", "concrete", "marble" ].map do |material_name|
  Material.find_or_create_by!(name: material_name)
end
puts "✅ Created #{materials.count} materials"

# Create Partners
partners = []
5.times do |i|
  partners << Partner.create!(
    name: "Partner #{i + 1}",
    geog: "SRID=4326;POINT(#{13.3 + rand * 0.2} #{52.4 + rand * 0.2})",  # Random Berlin coordinates
    operating_radius: rand(10..50),
    rating: rand(3.0..5.0).round(1)
  )
end
puts "✅ Created #{partners.count} partners"

# Assign Random Services to Partners
partners.each do |partner|
  selected_services = services.sample(rand(1..3))
  selected_services.each do |service|
    PartnerService.find_or_create_by!(partner: partner, service: service)
  end
end
puts "✅ Assigned services to partners"

# Assign Valid Materials to Services
valid_service_materials = {
  "flooring" => [ "wood", "tiles", "carpet", "concrete", "marble" ],
  "plumbing" => [ "concrete" ],
  "electrical" => [ "concrete" ],
  "painting" => [ "concrete", "wood" ],
  "roofing" => [ "tiles", "concrete", "marble" ]
}

valid_service_materials.each do |service_name, material_names|
  service = Service.find_by(name: service_name)
  material_names.each do |material_name|
    material = Material.find_by(name: material_name)
    ServiceMaterial.find_or_create_by!(service: service, material: material)
  end
end
puts "✅ Assigned materials to services"

puts "🎉 Seeding complete!"

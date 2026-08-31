return unless Rails.env.development?

admin = User.find_or_create_by!(email: "admin@oficina.test") do |user|
  user.name = "Administrador"
  user.password = "oficina123"
  user.role = "admin"
end

customer = Customer.find_or_initialize_by(document: "52998224725")
customer.assign_attributes(name: "Maria Souza", email: "maria@example.com", phone: "11999990000")
customer.save!

vehicle = customer.vehicles.find_or_initialize_by(plate: "ABC1D23")
vehicle.assign_attributes(brand: "Volkswagen", model: "Gol", year: 2020)
vehicle.save!

oil_change = CatalogService.find_or_create_by!(name: "Troca de óleo") do |service|
  service.description = "Troca de óleo do motor e verificação de filtros"
  service.price = 180.00
end

alignment = CatalogService.find_or_create_by!(name: "Alinhamento") do |service|
  service.description = "Alinhamento e balanceamento"
  service.price = 120.00
end

filter = Part.find_or_create_by!(sku: "FIL-001") do |part|
  part.name = "Filtro de óleo"
  part.unit_price = 45.90
  part.stock_quantity = 20
  part.minimum_stock = 5
end

oil = Part.find_or_create_by!(sku: "OLE-001") do |part|
  part.name = "Óleo 5W30 1L"
  part.unit_price = 39.90
  part.stock_quantity = 50
  part.minimum_stock = 10
end

puts "Seed ok: #{admin.email} / oficina123"
puts "Cliente #{customer.name} | OS de exemplo pode ser criada via API"
puts "Serviços: #{oil_change.name}, #{alignment.name} | Peças: #{filter.sku}, #{oil.sku}"

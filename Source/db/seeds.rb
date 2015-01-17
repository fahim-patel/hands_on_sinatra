require 'populator'
require 'faker'
Product.populate(20) do |product|
  product.name = Faker::Commerce.product_name
  product.price = Faker::Commerce.price
  product.description = Faker::Lorem.sentence
  product.status =  true
end


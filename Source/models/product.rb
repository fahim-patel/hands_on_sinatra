class Product < ActiveRecord::Base

  # Association
  has_and_belongs_to_many :carts
  has_and_belongs_to_many :orders	

  # Validation
  validates :name, :price, :description, :presence => true


end
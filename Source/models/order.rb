class Order < ActiveRecord::Base
  
  # Association	
  belongs_to :customer
  has_and_belongs_to_many :products

  default_scope  { order(:created_at => :desc) }
end
class Customer < ActiveRecord::Base

  # Association
  has_one :cart
  has_many :orders, dependent: :destroy

  # Validations
  validates :email, :firstname, :lastname, :password, presence: true
  validates :password, length: { minimum: 7 }

  def self.check(email_param, password_param)
    customer = Customer.find_by_email email_param
    if customer && customer.password == password_param
      customer
    else
      nil
    end
  end
  
end
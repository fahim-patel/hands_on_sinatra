require 'sinatra'
require 'sinatra/base'
require "sinatra/activerecord"
require './models/product'
require 'sinatra/contrib/all'
require 'pry'
require 'rake'
require 'sinatra/flash'
require 'rubygems'
require './models/customer'
require './models/cart'
require './models/order'
require "sinatra/cookies"
require 'faker'


use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/'
                           
helpers do
  def current_user
    @current_user ||= Customer.find_by_id(session[:customer_id]) if session[:customer_id]	
  end
end



# Handling request type
before /.*/ do
  if request.url.match(/.json$/)
    request.accept.unshift('application/json')
    request.path_info = request.path_info.gsub(/.json$/,'')
  end
end

get '/payment/default/:id' do
  erb :'payment/default'
end

############### Product Module Start ###################
# Index Products
get '/products', :provides => [:html, :json] do
  @products = Product.all	
  respond_to do |f|
    f.json { @products.to_json }
    f.html { erb :'products/index' }
  end
end

# New Product
get '/products/new', :provides => [:html] do
  @product = Product.new	
  erb :'products/new'
end

# Create Product
post '/products', :provides => [:html, :json] do
  @product = Product.new(params["product"])
  respond_to do |f|
    if @product.save
	  f.json { @product.to_json }
	  f.html { redirect to :'products' }
	  flash[:notice] = "Product created successfully"
	else
	  f.json { halt 500, @product.errors.to_json }
	  f.html { erb :'products/new' }
	end	
  end
end

# Edit Product
get '/products/:id/edit', :provides => [:html] do
  @product = Product.find_by_id(params[:id].to_i)
  respond_to do |f|
    if @product.present?
	  f.json { @product.to_json }
	  f.html { erb :'products/edit' }
	else
	  f.json { halt 404, "Product not available" }
	  f.html { redirect to :'products' }
	  flash[:notice] = "Something went wrong. Please search different item"
	end
   end	
end


# Update Product
post '/products/:id', :provides => [:html, :json] do
  @product = Product.find_by_id(params[:id].to_i)
  respond_to do |f|
    if @product.update_attributes(params[:product])
	  f.json { @product.to_json }
	  f.html { redirect to :"products/#{@product.id}" }
	  flash[:notice] = "Product updated successfully"
	else
	  f.json { halt 500, @product.errors.to_json }
	  f.html { erb :'products/edit' }
	end	
  end
end

# Show Product
get '/products/:id', :provides => [:html, :json] do
  @product = Product.find_by_id(params[:id].to_i)
  respond_to do |f|
    if @product.present?
	  f.json { @product.to_json }
	  f.html { erb :'products/show' }
	else
	  f.json { halt 404, "Product not available" }
	  f.html { redirect to :'products' }
	  flash[:notice] = "Something went wrong. Please search different item"
	end	
  end
end
############### Product Module End ###################


############### Auth Module Start ###################
get '/' do
  if !current_user	
    erb :login
  else
  	redirect to :"products"
  end	
end

post '/session' do
  customer = Customer.check(params[:customer][:email], params[:customer][:password])
  if customer
    session[:customer_id] = customer.id
    flash[:notice] = "Successfully login"
    redirect to :"products"
  else
    flash[:notice] = "Invalid email or password"
    redirect to :"/"
  end
end

get '/logout' do
  session[:customer_id] = nil
  flash[:notice] = "Logged out!"
  redirect to :"/"
end
############### Auth Module End ###################


############### Customer Module Start ###################
get '/customers/new' do
  @customer = Customer.new	
  erb :signup
end

# Create Customer
post '/customers', :provides => [:html, :json] do
  @customer = Customer.new params[:customer]
  respond_to do |f|
    if @customer.save
      @customer.create_cart	
	  f.json { @customer.to_json }
	  session[:customer_id] = @customer.id
	  f.html { redirect to :'products' }
	  flash[:notice] = "Successfully Created"
	else
	  f.json { halt 500, @customer.errors.to_json }
	  f.html { erb :'signup' }
	end	
  end
end
############### Customer Module End ###################


############### Cart Module Start ###################

# List products of carts
get '/carts', :provides => [:html, :json] do
  @products = current_user.cart.products	
  respond_to do |f|
    f.json { @products.to_json }
    f.html { erb :'carts/index' }
  end
end

# Add product to cart
get '/carts/add/:id', :provides => [:html, :json] do
  product = Product.find_by_id params[:id].to_i
  respond_to do |f|
	if product.present? 
	  if !current_user.cart.products.include?(product)
	    current_user.cart.products << product
	    f.json { current_user.cart.products.to_json }
	    flash[:notice] = "Product added successfully"
	    f.html { redirect to :'carts' }
	  else
	  	f.json { current_user.cart.products.to_json }
	    flash[:notice] = "Product already added in your cart"
	    f.html { redirect to :'carts' }
	  end
    else
	  f.json { halt 404, "Product not available" }
	  flash[:notice] = "Product not available"
	  f.html { redirect to :'products' }
	end 
  end
end
############### Cart Module End ###################


############### Order Module start ###################
# List orders
get '/orders', :provides => [:html, :json] do
  @orders = current_user.orders.includes(:products) rescue nil
  respond_to do |f|
  	f.json { @orders.to_json rescue nil }
    f.html { erb :'orders/index' }
  end
end

# Add product to cart
post '/order/add/:id', :provides => [:html, :json] do
  product = Product.find_by_id params[:id].to_i
  respond_to do |f|
  	if product.present? 
  		order = current_user.orders.create total_price: product.price, order_no: Faker::Number.number(10) 
	    order.products << product
	    f.json { order.to_json }
	    f.json { order.products.to_json }
	    flash[:notice] = "Your order added successfully"
	    f.html { redirect to :'orders' }
	else
	  f.json { halt 404, "Product not available" }
	  flash[:notice] = "Product not available"
	  f.html { redirect to :'products' }
	end 
  end
end



############### Order Module end ###################
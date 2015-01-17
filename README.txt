
App Name - Sinatra HandsOn

Steps to install solution-
1. cd Source
2. bundle install - to install gems. 
3. Update proper user and password (mysql) config/database.yml 
4. rake db:create - to create database
5. rake db:migrate - to create tables
6. rake db:seed - to load pre-data for app.
7. rerun 'ruby app.rb' - to start app. Mostly open in port 4567. Hit localhost:4567

Once app started you can do signup and check the app flow. 


User can do:
1. Login
2. Registration
3. Add Products
4. Edit Products
5. List Products
6. Add a product to a shopping cart.
7. Place an order.
8. View User Current Orders List. Ordered by date.
9. JSON endpoints



Note - 
1. Password saved as plain text.
2. No admin user. Any one can update product.

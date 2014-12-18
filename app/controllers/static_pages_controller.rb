class StaticPagesController < ApplicationController
 def index
 end

 def resp
 	#from = [38.5815719, -121.4943996] # Sacramento, US
	#to   = [37.3393857, -121.8949555] # San Jose, US
  puts 1
  from = Nominatim.search(params[:from]).limit(10).address_details(true).first
  puts 2
  to = Nominatim.search(params[:to]).limit(10).address_details(true).first

 	from = [from.lat, from.lon]
	to   = [to.lat, to.lon]
 	@response = Yournavigation.gosmore from, to
  puts 3
 	render json: @response
 end

end
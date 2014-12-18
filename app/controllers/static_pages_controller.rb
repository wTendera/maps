class StaticPagesController < ApplicationController
 def index
 end

 def resp
 	#from = [38.5815719, -121.4943996] # Sacramento, US
	#to   = [37.3393857, -121.8949555] # San Jose, US
  markers = []
  distance = 0
  traveltime = 0
  coordinates = []

  params[:tmp].each do |t|
    tmp = Nominatim.search(t).limit(10).address_details(true).first
    unless tmp 
      render json: [error: t + ": podany adres nie istnieje"]
      return
    end
    markers << [tmp.lat, tmp.lon]
  end

  markers.each_with_index do |t, index|
    unless index == markers.length() - 1
      response = Yournavigation.gosmore t, markers[index + 1]
      distance += response.distance
      traveltime += response.traveltime
      response.coordinates.each { |t| coordinates << t}
    end
  end

 	render json: [distance: distance, coordinates: coordinates, traveltime: traveltime, markers: markers]
 end

end
class StaticPagesController < ApplicationController
 def index
 end

 def resp
 	#from = [38.5815719, -121.4943996] # Sacramento, US
	#to   = [37.3393857, -121.8949555] # San Jose, US
 	from = [params[:fromx],params[:fromy] ]
	to   = [params[:tox], params[:toy]]
 	@response = Yournavigation.gosmore from, to
 	render json: @response
 end

end
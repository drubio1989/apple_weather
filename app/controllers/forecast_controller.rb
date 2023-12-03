class ForecastController < ApplicationController
  def search
    q = params[:query]
     coordinates = GeocodeService.get_lat_and_lon_from_location(q)
    
    if coordinates.empty?
      redirect_to root_path, alert: "Failed to locate the provided address. Please try again." and return
    end

    # @weather = ForecastService.get_current_forecast(lat, lon)
 
    
    render "home/index"
  end

  private
  
end
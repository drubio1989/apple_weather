class ForecastController < ApplicationController
  def search
    q = params[:query]
    coordinates = GeocodeService.get_lat_and_lon_from_location(q)
    
    if coordinates.empty?
      redirect_to root_path, alert: "Failed to locate the provided address. Please try again." 
      return
    end

    @weather = ForecastService.get_forecast(coordinates)

    if @weather.nil?
      redirect_to root_path, alert: "Could not retrieve the current forecast for #{q}. Please try again later." 
      return
    end
 
    render "home/index"
  end
end
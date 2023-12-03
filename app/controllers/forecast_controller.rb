class ForecastController < ApplicationController
  def search
    q = params[:query]
    lat, lon = GeocodeService.get_lat_and_lon_from_location(q)

    response = ForecastService.get_forecast(lat, lon)
    if response.success?
      @weather = response.body
    end
  
    render "home/index"
  end
end
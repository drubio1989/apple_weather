class ForecastController < ApplicationController
  def search
    q = params[:query]
    zipcode = GeocodeService.get_zipcode_from_location(q)
    
    if zipcode.nil?
      redirect_to root_path, alert: "Failed to locate the provided address. Please try again." 
      return
    end

    @weather = ForecastService.get_forecast(zipcode)

    if @weather.nil?
      redirect_to root_path, alert: "Could not retrieve the current forecast for #{q}. Please try again later." 
      return
    end
 
    render "home/index"
  end
end
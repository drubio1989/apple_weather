class ForecastController < ApplicationController
  def search
    q = params[:query]
 
    zip_code = GeocodeService.get_zip_code_from_location(q)

    if zip_code.nil?
      redirect_to root_path, alert: "Failed to locate the provided address. Please try again." 
      return
    end

    @forecast_data = ForecastService.get_forecast(zip_code)

    if @forecast_data[:data].nil?
      redirect_to root_path, alert: "Could not retrieve the current forecast for #{q}. Please try again later." 
      return
    end
 
    render "home/index"
  end
end
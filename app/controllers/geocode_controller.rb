class GeocodeController < ApplicationController
  def search
    q = params[:query]
    address = JSON.parse(GeocodeService.get_address(q))["items"][0]["position"]
    @weather = ForecastService.get_forecast(address["lat"], address["lng"])
    render json: @weather
  end
end
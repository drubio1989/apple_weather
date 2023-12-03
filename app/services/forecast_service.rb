class ForecastService
  def self.get_forecast(lat, lon)
    open_weather_url ="http://api.openweathermap.org"
    api_key = Rails.application.credentials.open_weather.access_key_id
    data = Faraday.get("#{open_weather_url}/data/3.0/onecall?lat=#{lat}&lon=#{lon}&exclude=minutely,hourly,daily,alerts&appid=#{api_key}").body
  end
end
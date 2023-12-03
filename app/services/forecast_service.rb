class ForecastService
  BASE_URL = "http://api.openweathermap.org/data/3.0/onecall".freeze
  API_KEY = Rails.application.credentials.open_weather.access_key_id

  def self.get_forecast(lat, lon, exclude = %w[minutely hourly daily alerts])
    begin
      conn = build_connection(lat, lon, exclude)
      response = conn.get
    rescue Faraday::Error => e

      raise e
    end
  end

  private

  def self.build_connection(lat, lon, exclude)
    Faraday.new(url: BASE_URL) do |builder|
      builder.request :json
      builder.request :url_encoded
      builder.response :json
      builder.adapter :net_http

      builder.params['lat'] = lat
      builder.params['lon'] = lon
      builder.params['exclude'] = exclude.join(',')
      builder.params['apiKey'] = API_KEY
      builder.headers['Content-Type'] = 'application/json'
      builder.use Faraday::Response::RaiseError
    end
  end
end
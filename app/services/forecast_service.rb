class ForecastService
  BASE_URL = "http://api.openweathermap.org/data/3.0/onecall".freeze
  API_KEY = Rails.application.credentials.open_weather.access_key_id

  def self.get_forecast(coordinates, exclude = %w[minutely hourly daily alerts])
    begin
      conn = build_connection('poop', exclude)
      handle_response(conn.get)
    rescue Faraday::Error => e
      # logger.error "[error] Forecast Service error: #{e.response[:status]}"
      # logger.error "[error] Forecast Service error: #{e.response[:body]}"
      # logger.error "[error] Forecast Service error: lookup performed with lat=#{lat} and lon=#{lon}"

      nil
    end
  end

  private

  def self.handle_response(response)
    response.success? ? response.body : nil
  end

  def self.logger
    @logger ||= Logger.new("#{Rails.root}/log/forecast-service-api.log")
  end

  def self.build_connection(coordinates, exclude)
    Faraday.new(url: BASE_URL) do |builder|
      builder.request :json
      builder.request :url_encoded
      builder.response :json
      builder.adapter :net_http

      builder.params['lat'] = coordinates.first
      builder.params['lon'] = coordinates.last
      builder.params['exclude'] = exclude.join(',')
      builder.params['apiKey'] = API_KEY
      builder.headers['Content-Type'] = 'application/json'
    end
  end
end
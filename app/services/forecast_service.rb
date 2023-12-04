class ForecastService
  FORECAST_BASE_URL = "http://api.weatherstack.com/current".freeze
  API_KEY = Rails.application.credentials.weather_stack.access_key_id

  def self.get_forecast(zip_code)
    begin
      from_cache = true

      data = Rails.cache.fetch("forecast_#{zip_code}", expires_in: 30.minutes) do
        from_cache = false 
        conn = build_connection(zip_code)
        handle_response(conn.get)
      end

      { data: data, from_cache: from_cache }
    rescue Faraday::Error => e
      logger.error "[error] Forecast Service error: #{e.message}"
      logger.error "[error] Forecast Service error: lookup performed with zip_code=#{zip_code}"

      { data: nil, from_cache: false}
    end
  end

  private

  def self.handle_response(response)
    response.success? ? response.body : nil
  end

  def self.logger
    @logger ||= Logger.new("#{Rails.root}/log/forecast-service-api.log")
  end

  def self.build_connection(zip_code)
    Faraday.new(url: FORECAST_BASE_URL) do |builder|
      builder.request :json
      builder.request :url_encoded
      builder.response :json
      builder.adapter :net_http

      builder.params['query'] = zip_code
      builder.params['units'] = 'f'
      builder.params['access_key'] = API_KEY
      builder.headers['Content-Type'] = 'application/json'
    end
  end
end
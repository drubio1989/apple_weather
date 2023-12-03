class GeocodeService
  BASE_URL = "https://geocode.search.hereapi.com/v1/geocode".freeze
  API_KEY = Rails.application.credentials.here.access_key_id

  def self.get_lat_and_lon_from_location(q)
    begin
      conn = build_connection(q)
      response = conn.get
      
      if response.success? && response.body["items"].present?
        extract_lat_and_lon(response.body["items"].first)
      else
        raise Faraday::Error
      end
    rescue Faraday::Error => e
      logger.error "[error] Geocode Service error: #{e.response[:status]}"
      logger.error "[error] Geocode Service error: #{e.response[:headers]}"
      logger.error "[error] Geocode Service error: #{e.response[:body]}"
      logger.error "[error] Geocode Service error: #{e.response[:request][:url_path]}"
      raise e
    end
  end

  private

  def self.extract_lat_and_lon(location)
    lat, lon = location.dig("position", "lat"), location.dig("position", "lng")
  end

  def self.build_connection(q)
    Faraday.new(url: BASE_URL) do |builder|
      builder.request :json
      builder.request :url_encoded
      builder.response :json
      builder.adapter :net_http

      builder.params['q'] = q
      builder.params['limit'] = 1
      builder.params['apiKey'] = API_KEY
      builder.headers['Content-Type'] = 'application/json'
      builder.use Faraday::Response::RaiseError
    end
  end
end
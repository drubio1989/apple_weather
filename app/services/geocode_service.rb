class GeocodeService
  BASE_URL = "https://geocode.search.hereapi.com/v1/geocode".freeze
  API_KEY = Rails.application.credentials.here.access_key_id

  def self.get_lat_and_lon_from_location(q)
    begin
      conn = build_connection(q)
      response_handler(conn.get)
    rescue Faraday::Response::RaiseError => e
      logger.error "[error] Geocode Service error: #{e.response[:status]}"
      logger.error "[error] Geocode Service error: #{e.response[:body]}"
      logger.error "[error] Geocode Service error: search performed with q=#{q}"

      []
    end
  end

  private

  def handle_response(response)
    return [] unless response.success? && response.body["items"].present?

    extract_lat_and_lon(response.body["items"].first)
  end

  def logger
    @logger ||= Logger.new("#{Rails.root}/log/geoservice-api.log")
  end

  def self.extract_lat_and_lon(location)
    lat = location.dig("position", "lat")
    lon  = location.dig("position", "lng")
    
    return [] if lat.nil? || long.nil?

    # Do some kind of caching with this
    # Make a low level cache.
    postal_code = location.dig("address", "postalCode")

    [lat, lon]
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
class GeocodeService
  GEOCODE_BASE_URL = "http://api.weatherstack.com/current".freeze
  API_KEY = Rails.application.credentials.here.access_key_id

  def self.get_zipcode_from_location(q)
    begin
      conn = build_connection(q)
      handle_response(conn.get)
    rescue Faraday::Error => e
      # logger.error "[error] Geocode Service error: #{e.response[:status]}"
      # logger.error "[error] Geocode Service error: #{e.response[:body]}"
      # logger.error "[error] Geocode Service error: search performed with q=#{q}"

      []
    end
  end

  private

  def self.handle_response(response)
    return [] unless response.success? && response.body["items"].present?

    extract_zipcode(response.body["items"].first)
  end

  def self.logger
    @logger ||= Logger.new("#{Rails.root}/log/geoservice-api.log")
  end

  def self.extract_zipcode(location)
     zipcode_code = location.dig("address", "postalCode")
     zipcode_code.nil? ? nil : zipcode
  end

  def self.build_connection(q)
    Faraday.new(url: GEOCODE_BASE_URL) do |builder|
      builder.request :json
      builder.request :url_encoded
      builder.response :json
      builder.adapter :net_http

      builder.params['q'] = q
      builder.params['limit'] = 1
      builder.params['apiKey'] = API_KEY
      builder.headers['Content-Type'] = 'application/json'
    end
  end
end
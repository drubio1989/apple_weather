class GeocodeService
  GEOCODE_BASE_URL = "https://geocode.search.hereapi.com/v1/geocode".freeze
  API_KEY = Rails.application.credentials.here.access_key_id

  def self.get_zip_code_from_location(q)
    begin
      data = Rails.cache.fetch("geocode_#{q}", expires_in: 1.minute) do
        conn = build_connection(q)
        handle_response(conn.get)
      end
    rescue Faraday::Error => e
      logger.error "[error] Geocode Service error: #{e.response[:status]}"
      logger.error "[error] Geocode Service error: #{e.response[:body]}"
      logger.error "[error] Geocode Service error: search performed with q=#{q}"

      nil
    end
  end

  private

  def self.handle_response(response)
    return nil unless response.success? && response.body["items"].present?

    extract_zip_code(response.body["items"].first)
  end

  def self.logger
    @logger ||= Logger.new("#{Rails.root}/log/geoservice-api.log")
  end

  def self.extract_zip_code(location)
     zip_code = location.dig("address", "postalCode")
     zip_code.nil? ? nil : zip_code
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
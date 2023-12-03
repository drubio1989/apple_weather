class GeocodeService
  def self.get_address(q)
    api_key = Rails.application.credentials.here.access_key_id
    geo_response = Faraday.get("https://geocode.search.hereapi.com/v1/geocode?q=#{q}&apiKey=#{api_key}")
    data = geo_response.body
  end
end
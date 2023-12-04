require 'rails_helper'

RSpec.describe ForecastController, type: :request do
  describe 'GET #search' do

    # Todo: Use vcr for http interaction
    let(:valid_data) do
      {
        data: {
          location: {
            name: 'New York',
            country: 'United States of America',
            region: 'New York',
            lat: '40.714',
            lon: '-74.006',
            timezone_id: 'America/New_York',
            localtime: '2019-09-07 08:14',
            localtime_epoch: 1567844040,
            utc_offset: '-4.0'
          },
          current: {
            observation_time: '12:14 PM',
            temperature: 13,
            weather_code: 113,
            weather_icons: [
              'https://assets.weatherstack.com/images/wsymbols01_png_64/wsymbol_0001_sunny.png'
            ],
            weather_descriptions: ['Sunny'],
            wind_speed: 0,
            wind_degree: 349,
            wind_dir: 'N',
            pressure: 1010,
            precip: 0,
            humidity: 90,
            cloudcover: 0,
            feelslike: 13,
            uv_index: 4,
            visibility: 16
          }
        }
      }.to_json
    end
  
    context 'when providing a valid location' do
      it 'assigns the forecast to @forecast' do
        allow(GeocodeService).to receive(:get_zip_code_from_location).and_return('37203')
        allow(ForecastService).to receive(:get_forecast).and_return(JSON.parse(valid_data))

        get '/search', params: { query: '1234 Apple Street, Waco TX' }

        expect(assigns(:forecast)).to eq(JSON.parse(valid_data))
      end

    end

    context 'when providing an invalid location' do
      it 'redirects to root_path with an alert' do
        allow(GeocodeService).to receive(:get_zip_code_from_location).and_return(nil)

        get '/search', params: { query: 'invalid_location' }

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('Failed to locate the provided address. Please try again.')
      end
    end

    context 'when forecast retrieval fails' do
      it 'redirects to root_path with an alert' do
        allow(GeocodeService).to receive(:get_zip_code_from_location).and_return('12345')
        allow(ForecastService).to receive(:get_forecast).and_return(data: nil)

        get '/search', params: { query: '1234 Apple Street, Waco TX' }

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Could not retrieve the current forecast for 1234 Apple Street, Waco TX. Please try again later.")
      end
    end
  end
end
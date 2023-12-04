require 'rails_helper'

RSpec.describe ForecastService, type: :class do
  describe '.get_forecast' do
    let(:valid_response) { { 'temperature' => '72', 'conditions' => 'Clear' } }
  

    context 'with a successful response' do
      it 'returns the forecast data' do
        allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(double(success?: true, body: valid_response))

        result = ForecastService.get_forecast('12345')
        expect(result[:data]).to eq(valid_response)
      end
    end

    context 'with an unsuccessful response' do
      it 'returns nil data' do
        allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(double(success?: false, response: { status: 500, body: 'Error' }))

        result = ForecastService.get_forecast('12345')

        expect(result[:data]).to be_nil
      end
    end

    context 'when an exception is raised' do
      it 'logs the error and returns nil data' do
        allow(ForecastService).to receive(:build_connection).and_raise(Faraday::Error.new('Error'))

        allow(Rails.logger).to receive(:error).and_call_original

        result = ForecastService.get_forecast('12345')

        expect(result[:data]).to be_nil
      end
    end
  end

  describe '.handle_response' do
    context 'with a successful response' do
      it 'returns the response body' do
        response = double(success?: true, body: { 'temperature' => 72, 'conditions' => 'Clear' })

        data = ForecastService.send(:handle_response, response)

        expect(data).to eq(response.body)
      end
    end

    context 'with an unsuccessful response' do
      it 'returns nil' do
        response = double(success?: false, body: { 'error' => { 'info' => 'Some error' } })

        data = ForecastService.send(:handle_response, response)

        expect(data).to be_nil
      end
    end
  end
end

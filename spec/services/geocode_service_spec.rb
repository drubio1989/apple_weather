require 'rails_helper'

RSpec.describe GeocodeService, type: :class do
  describe '.get_zip_code_from_location' do
    let(:valid_response) do
      {
        'items' => [
          {
            'address' => {
              'postalCode' => '12345'
            }
          }
        ]
      }
    end

    context 'with a successful response' do
      it 'returns the zip code' do
        allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(double(success?: true, body: valid_response))

        zip_code = GeocodeService.get_zip_code_from_location('some_location')

        expect(zip_code).to eq('12345')
      end
    end

    context 'with an unsuccessful response' do
      it 'returns nil' do
        allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(double(success?: false, response: { status: 500, body: 'Error' }))

        zip_code = GeocodeService.get_zip_code_from_location('some_location')

        expect(zip_code).to be_nil
      end
    end

    context 'when an exception is raised' do
      it 'logs the error and returns nil' do
        allow(GeocodeService).to receive(:build_connection).and_raise(Faraday::Error.new('Error'))

        allow(Rails.logger).to receive(:error).and_call_original

        zip_code = GeocodeService.get_zip_code_from_location('some_location')

        expect(zip_code).to be_nil
      end
    end
  end

  describe '.handle_response' do
    context 'with a successful response containing a zip code' do
      it 'returns the zip code' do
        response = double(success?: true, body: { 'items' => [{ 'address' => { 'postalCode' => '12345' } }] })

        zip_code = GeocodeService.send(:handle_response, response)

        expect(zip_code).to eq('12345')
      end
    end

    context 'with an unsuccessful response' do
      it 'returns nil' do
        response = double(success?: false, body: { 'items' => [] })

        zip_code = GeocodeService.send(:handle_response, response)

        expect(zip_code).to be_nil
      end
    end
  end

  describe '.extract_zip_code' do
    context 'with a location containing a zip code' do
      it 'returns the zip code' do
        location = { 'address' => { 'postalCode' => '12345' } }

        zip_code = GeocodeService.send(:extract_zip_code, location)

        expect(zip_code).to eq('12345')
      end
    end

    context 'with a location not containing a zip code' do
      it 'returns nil' do
        location = { 'address' => {} }

        zip_code = GeocodeService.send(:extract_zip_code, location)

        expect(zip_code).to be_nil
      end
    end
  end
end

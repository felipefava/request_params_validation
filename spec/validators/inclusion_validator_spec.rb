RSpec.shared_examples 'validates inclusion' do
  describe 'inclusion validator' do
    let(:request_params) { { key: key_value } }

    let(:define_params) { -> (params) { params.optional :key, inclusion: inclusion } }

    before { post :dummy, body: request_params.to_json, as: :json }

    context 'when inclusion is an array' do
      let(:inclusion) { [1, 'some value', false] }

      context 'and value is valid' do
        let(:key_value) { inclusion.sample }

        it { expect(response).to have_http_status(200) }
      end

      context 'and value is invalid' do
        let(:key_value) { [2, 'another value', true].sample }

        it { expect(response).to have_http_status(422) }

        it 'has the correct error messages' do
          expect(response.body).to eq({
            status: :error,
            key: 'RequestParamsValidation::InvalidParameterValueError',
            message: "The value for the parameter 'key' is invalid. Value should be in #{inclusion}"
          }.to_json)
        end
      end
    end

    context 'when inclusion is a hash with custom message' do
      let(:message) { 'My custom message' }
      let(:inclusion) { { in: [1, 2, 3, 4, 5], message: message } }

      context 'and value is valid' do
        let(:key_value) { inclusion[:in].sample }

        it { expect(response).to have_http_status(200) }
      end

      context 'and value is invalid' do
        let(:key_value) { 0 }

        it { expect(response).to have_http_status(422) }

        it 'has the correct error messages' do
          expect(response.body).to eq({
            status: :error,
            key: 'RequestParamsValidation::InvalidParameterValueError',
            message: "The value for the parameter 'key' is invalid. #{message}"
          }.to_json)
        end
      end
    end
  end
end

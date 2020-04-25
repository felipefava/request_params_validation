RSpec.shared_examples 'validates value' do
  describe 'value validator' do
    let(:request_params) { { key: key_value } }

    let(:min) { nil }
    let(:max) { nil }
    let(:message) { nil }
    let(:value_option) { { min: min, max: max, message: message } }

    let(:define_params) { -> (params) { params.optional :key, value: value_option } }

    before { post :dummy, body: request_params.to_json, as: :json }

    context 'when value option has only min' do
      let(:min) { 1_000 }

      context 'and value is valid' do
        let(:key_value) { rand(1_000..1_000_000) }

        it { expect(response).to have_http_status(200) }
      end

      context 'and value is invalid' do
        let(:key_value) { rand(0..999) }

        it { expect(response).to have_http_status(422) }

        it 'has the correct error messages' do
          expect(response.body).to eq({
            status: :error,
            key: 'RequestParamsValidation::InvalidParameterValueError',
            message: "The value for the parameter 'key' is invalid. Value shoud be greater or " \
                     "equal than 1000"
          }.to_json)
        end
      end
    end

    context 'when value option has only max' do
      let(:max) { 1_000 }

      context 'and value is valid' do
        let(:key_value) { rand(0..1_000) }

        it { expect(response).to have_http_status(200) }
      end

      context 'and value is invalid' do
        let(:key_value) { rand(1_001..1_000_000) }

        it { expect(response).to have_http_status(422) }

        it 'has the correct error messages' do
          expect(response.body).to eq({
            status: :error,
            key: 'RequestParamsValidation::InvalidParameterValueError',
            message: "The value for the parameter 'key' is invalid. Value shoud be less or " \
                     "equal than 1000"
          }.to_json)
        end
      end
    end

    context 'when value option has min and max' do
      let(:min) { 500}
      let(:max) { 1_000 }

      context 'and value is valid' do
        let(:key_value) { rand(500..1_000) }

        it { expect(response).to have_http_status(200) }
      end

      context 'and value is invalid' do
        let(:key_value) { [rand(0..499), rand(1_001..1_000_000)].sample }

        it { expect(response).to have_http_status(422) }

        it 'has the correct error messages' do
          expect(response.body).to eq({
            status: :error,
            key: 'RequestParamsValidation::InvalidParameterValueError',
            message: "The value for the parameter 'key' is invalid. Value shoud be between " \
                     "500 and 1000"
          }.to_json)
        end
      end
    end

    context 'when value option has message' do
      let(:min) { 1 }
      let(:message) { 'My custom message' }

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

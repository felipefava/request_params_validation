RSpec.shared_examples 'validates length' do
  describe 'length validator' do
    let(:request_params) { { key: key_value } }

    let(:define_params) { -> (params) { params.optional :key, length: length } }

    before { post :dummy, body: request_params.to_json, as: :json }

    context 'when length is an integer' do
      let(:length) { 4 }

      context 'and value is valid' do
        let(:key_value) { ['some', [1,2,3,4], '4444'].sample }

        it { expect(response).to have_http_status(200) }
      end

      context 'and value is invalid' do
        let(:key_value) { ['long value', 'sho', [1,2]].sample }

        it { expect(response).to have_http_status(422) }

        it 'has the correct error messages' do
          expect(response.body).to eq({
            status: :error,
            key: 'RequestParamsValidation::InvalidParameterValueError',
            message: "The value for the parameter 'key' is invalid. Length shoud be equal to 4"
          }.to_json)
        end
      end
    end

    context 'when length is a hash' do
      let(:min) { nil }
      let(:max) { nil }
      let(:message) { nil }

      let(:length) { { min: min, max: max, message: message } }

      context 'and has only min' do
        let(:min) { 2 }

        context 'and value is valid' do
          let(:key_value) { ['..', [1,2,3,4], :haaaaaa].sample }

          it { expect(response).to have_http_status(200) }
        end

        context 'and value is invalid' do
          let(:key_value) { ['a', [], '1'].sample }

          it { expect(response).to have_http_status(422) }

          it 'has the correct error messages' do
            expect(response.body).to eq({
              status: :error,
              key: 'RequestParamsValidation::InvalidParameterValueError',
              message: "The value for the parameter 'key' is invalid. Length shoud be greater or " \
                       "equal than 2"
            }.to_json)
          end
        end
      end

      context 'and has only max' do
        let(:max) { 2 }

        context 'and value is valid' do
          let(:key_value) { ['.', [], '22'].sample }

          it { expect(response).to have_http_status(200) }
        end

        context 'and value is invalid' do
          let(:key_value) { ['123', [1,2,3,4], 'haaaaaaaaa'].sample }

          it { expect(response).to have_http_status(422) }

          it 'has the correct error messages' do
            expect(response.body).to eq({
              status: :error,
              key: 'RequestParamsValidation::InvalidParameterValueError',
              message: "The value for the parameter 'key' is invalid. Length shoud be less or " \
                       "equal than 2"
            }.to_json)
          end
        end
      end

      context 'and has min and max' do
        let(:min) { 2 }
        let(:max) { 4 }

        context 'and value is valid' do
          let(:key_value) { ['..', [1,2,3], '4444'].sample }

          it { expect(response).to have_http_status(200) }
        end

        context 'and value is invalid' do
          let(:key_value) { ['.', [1,2,3,4,5], 'haaaaaaaaa'].sample }

          it { expect(response).to have_http_status(422) }

          it 'has the correct error messages' do
            expect(response.body).to eq({
              status: :error,
              key: 'RequestParamsValidation::InvalidParameterValueError',
              message: "The value for the parameter 'key' is invalid. Length shoud be between 2 " \
                       "and 4"
            }.to_json)
          end
        end
      end

      context 'and has message' do
        let(:min) { 2 }
        let(:max) { 2 }
        let(:message) { 'My custom message' }

        let(:key_value) { ['.', [1,2,3], 'haaaaaaaaa'].sample }

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

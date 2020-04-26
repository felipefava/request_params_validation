RSpec.shared_examples 'validates length' do
  describe 'length validator' do
    let(:define_params) { -> (params) { params.optional :key, length: length } }

    let(:request_params) { { key: key_value } }

    before { post :dummy, body: request_params.to_json, as: :json }

    context 'when length option is an integer' do
      let(:length) { 4 }

      let(:key_value) { ['some', [1, 2, 3, 4], '4444'].sample }

      it { expect(response).to have_http_status(200) }

      context 'when parameter value is invalid' do
        let(:key_value) { ['long value', 'sho', [1, 2]].sample }

        it { expect(response).to have_http_status(422) }

        it 'returns the correct error message' do
          expect(response.body).to eq({
            status: :error,
            key: 'RequestParamsValidation::InvalidParameterValueError',
            message: "The value for the parameter 'key' is invalid. Length shoud be equal to #{length}"
          }.to_json)
        end
      end
    end

    context 'when length option is a hash' do
      let(:min) { nil }
      let(:max) { nil }
      let(:message) { nil }

      let(:length) { { min: min, max: max, message: message } }

      context 'when only the min option is set' do
        let(:min) { 2 }

        let(:key_value) { ['..', [1, 2, 3, 4], :longer_symbol].sample }

        it { expect(response).to have_http_status(200) }

        context 'when parameter value is invalid' do
          let(:key_value) { ['.', [], '1'].sample }

          it { expect(response).to have_http_status(422) }

          it 'returns the correct error message' do
            expect(response.body).to eq({
              status: :error,
              key: 'RequestParamsValidation::InvalidParameterValueError',
              message: "The value for the parameter 'key' is invalid. Length shoud be greater or " \
                       "equal than #{min}"
            }.to_json)
          end

          context 'when the message option is set' do
            let(:message) { 'My custom message' }

            it { expect(response).to have_http_status(422) }

            it 'returns the correct error message' do
              expect(response.body).to eq({
                status: :error,
                key: 'RequestParamsValidation::InvalidParameterValueError',
                message: "The value for the parameter 'key' is invalid. #{message}"
              }.to_json)
            end
          end
        end
      end

      context 'when only the max option is set' do
        let(:max) { 2 }

        let(:key_value) { ['.', [], '22'].sample }

        it { expect(response).to have_http_status(200) }

        context 'when parameter value is invalid' do
          let(:key_value) { ['...', [1, 2, 3, 4], 'longer value than allowed'].sample }

          it { expect(response).to have_http_status(422) }

          it 'returns the correct error message' do
            expect(response.body).to eq({
              status: :error,
              key: 'RequestParamsValidation::InvalidParameterValueError',
              message: "The value for the parameter 'key' is invalid. Length shoud be less or " \
                       "equal than #{max}"
            }.to_json)
          end

          context 'when the message option is set' do
            let(:message) { 'My custom message' }

            it { expect(response).to have_http_status(422) }

            it 'returns the correct error message' do
              expect(response.body).to eq({
                status: :error,
                key: 'RequestParamsValidation::InvalidParameterValueError',
                message: "The value for the parameter 'key' is invalid. #{message}"
              }.to_json)
            end
          end
        end
      end

      context 'when the min and max options are set' do
        let(:min) { 2 }
        let(:max) { 4 }

        let(:key_value) { ['..', [1, 2, 3], '4444'].sample }

        it { expect(response).to have_http_status(200) }

        context 'when parameter value is invalid' do
          let(:key_value) { ['.', [1, 2, 3, 4, 5], 'longer value than allowed'].sample }

          it { expect(response).to have_http_status(422) }

          it 'returns the correct error message' do
            expect(response.body).to eq({
              status: :error,
              key: 'RequestParamsValidation::InvalidParameterValueError',
              message: "The value for the parameter 'key' is invalid. Length shoud be between " \
                       "#{min} and #{max}"
            }.to_json)
          end

          context 'when the message option is set' do
            let(:message) { 'My custom message' }

            it { expect(response).to have_http_status(422) }

            it 'returns the correct error message' do
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
  end
end

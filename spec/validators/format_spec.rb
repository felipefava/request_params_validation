RSpec.shared_examples 'validates format' do
  describe 'format validator' do
    let(:request_params) { { key: key_value } }

    let(:define_params) { -> (params) { params.optional :key, format: format } }

    before { post :dummy, body: request_params.to_json, as: :json }

    context 'when format is a regexp' do
      let(:format) { /^start .* end$/ }

      context 'and value is valid' do
        let(:key_value) { 'start some-value end' }

        it { expect(response).to have_http_status(200) }
      end

      context 'and value is invalid' do
        let(:key_value) { 'invalid value' }

        it { expect(response).to have_http_status(422) }

        it 'has the correct error messages' do
          expect(response.body).to eq({
            status: :error,
            key: 'RequestParamsValidation::InvalidParameterValueError',
            message: "The value for the parameter 'key' is invalid. Value format is invalid"
          }.to_json)
        end
      end
    end

    context 'when format is a hash' do
      let(:regexp) { /^1.*/ }
      let(:message) { nil }
      let(:format) { { regexp: regexp, message: message } }

      context 'and value is valid' do
        let(:key_value) { '1 some value' }

        it { expect(response).to have_http_status(200) }
      end

      context 'and value is invalid' do
        let(:key_value) { 'do not start with 1' }

        it { expect(response).to have_http_status(422) }

        it 'has the correct error messages' do
          expect(response.body).to eq({
            status: :error,
            key: 'RequestParamsValidation::InvalidParameterValueError',
            message: "The value for the parameter 'key' is invalid. Value format is invalid"
          }.to_json)
        end

        context 'and has message' do
          let(:message) { 'My custom message' }

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
end

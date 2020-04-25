RSpec.shared_examples 'validates custom validations' do
  describe 'custom validator' do
    let(:request_params) { { key: key_value } }

    let(:define_params) do
      -> (params) { params.optional :key, type: :date, validate: custom_validation }
    end

    before { post :dummy, body: request_params.to_json, as: :json }

    context 'when custom validation is a proc' do
      let(:custom_validation) { -> (value) { value <= 1.years.ago.to_date } }

      context 'and value is valid' do
        let(:key_value) { '2019-02-02' }

        it { expect(response).to have_http_status(200) }
      end

      context 'and value is invalid' do
        let(:key_value) { 6.months.ago.to_date }

        it { expect(response).to have_http_status(422) }

        it 'has the correct error messages' do
          expect(response.body).to eq({
            status: :error,
            key: 'RequestParamsValidation::InvalidParameterValueError',
            message: "The value for the parameter 'key' is invalid"
          }.to_json)
        end
      end
    end

    context 'when custom validation is a hash' do
      let(:function) { -> (value) { value >= Date.today } }
      let(:message) { nil }
      let(:custom_validation) { { function: function, message: message } }

      context 'and value is valid' do
        let(:key_value) { Date.tomorrow.to_s }

        it { expect(response).to have_http_status(200) }
      end

      context 'and value is invalid' do
        let(:key_value) { Date.yesterday.to_s }

        it { expect(response).to have_http_status(422) }

        it 'has the correct error messages' do
          expect(response.body).to eq({
            status: :error,
            key: 'RequestParamsValidation::InvalidParameterValueError',
            message: "The value for the parameter 'key' is invalid"
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

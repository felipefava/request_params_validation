RSpec.shared_examples 'validates custom validations' do
  describe 'custom validator' do
    let(:define_params) do
      -> (params) { params.optional :key, type: :date, validate: custom_validation }
    end

    let(:request_params) { { key: key_value } }

    before { post :dummy, body: request_params.to_json, as: :json rescue nil }

    context 'when custom validation option is a proc' do
      let(:custom_validation) { -> (value) { value <= 1.years.ago.to_date } }

      let(:key_value) { 13.months.ago.to_date.to_s }

      it { expect(response).to have_http_status(200) }

      context 'when parameter value is invalid' do
        let(:key_value) { 6.months.ago.to_date.to_s }

        it { expect(response).to have_http_status(422) }

        it 'returns the correct error' do
          expect(response.body).to eq(build_error_response(:invalid_param, param_key: :key))
        end

        describe 'custom exception for custom validations' do
          class CustomExceptionOnCustomValidation < StandardError
            def initialize(options)
              super('Error on custom exception')
            end
          end

          let(:exception_on_invalid_parameter_custom_validation) { CustomExceptionOnCustomValidation }

          subject { post :dummy, body: request_params.to_json, as: :json }

          it 'calls the exception with the right parameters' do
            expect(CustomExceptionOnCustomValidation).to receive(:new).with(
              param_key: :key,
              param_type: :date,
              param_value: key_value,
              details: nil
            )

            subject rescue nil
          end

          it 'raises the right exception' do
            expect { subject }.to raise_error(
              CustomExceptionOnCustomValidation,
              'Error on custom exception'
            )
          end
        end
      end
    end

    context 'when custom validation option is a hash' do
      let(:function) { -> (value) { value >= Date.today } }
      let(:message) { nil }
      let(:custom_validation) { { function: function, message: message } }

      let(:key_value) { Date.today.to_s }

      it { expect(response).to have_http_status(200) }

      context 'when parameter value is invalid' do
        let(:key_value) { Date.today.prev_day.to_s }

        it { expect(response).to have_http_status(422) }

        it 'returns the correct error' do
          expect(response.body).to eq(build_error_response(:invalid_param, param_key: :key))
        end

        context 'when the message option is set' do
          let(:message) { 'My custom message' }

          it { expect(response).to have_http_status(422) }

          it 'returns the correct error message' do
            expect(response.body).to eq(
              build_error_response(:invalid_param, param_key: :key, details: message)
            )
          end
        end
      end
    end
  end
end

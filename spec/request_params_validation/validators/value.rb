require_relative '../../shared/element_of_an_array_with_error'

RSpec.shared_examples 'validates value size' do
  describe 'value validator' do
    let(:min) { nil }
    let(:max) { nil }
    let(:message) { nil }
    let(:value_option) { { min: min, max: max, message: message } }

    let(:define_params) { -> (params) { params.optional :key, value: value_option } }

    let(:request_params) { { key: key_value } }

    before { post :dummy, body: request_params.to_json, as: :json rescue nil }

    context 'when only the min option is set' do
      let(:min) { 1_000 }

      let(:key_value) { rand(1_000..100_000_000) }

      it { expect(response).to have_http_status(200) }

      context 'when parameter value is invalid' do
        let(:key_value) { rand(0..999) }

        it { expect(response).to have_http_status(422) }

        it 'returns the correct error message' do
          expect(response.body).to eq(
            build_error_response(
              :invalid_param,
              param_key: :key, details: "Value should be greater or equal than #{min}"
            )
          )
        end

        context 'when the message option is set' do
          let(:message) { 'My custom message' }

          it 'returns the correct error message' do
            expect(response.body).to eq(
              build_error_response(:invalid_param, param_key: :key, details: message)
            )
          end

          it_behaves_like 'an element of an array with value error'
        end

        it_behaves_like 'an element of an array with value error'

        describe 'custom exception for value validations' do
          class CustomExceptionOnValueValidation < StandardError
            def initialize(_options)
              super('Error on custom exception')
            end
          end

          let(:exception_on_invalid_parameter_value_size) { CustomExceptionOnValueValidation }

          subject { post :dummy, body: request_params.to_json, as: :json }

          it 'calls the exception with the right parameters' do
            expect(CustomExceptionOnValueValidation).to receive(:new).with(
              param_key: :key,
              param_type: nil,
              param_value: key_value,
              min: min,
              max: max,
              details: "Value should be greater or equal than #{min}"
            )

            subject rescue nil
          end

          it 'raises the right exception' do
            expect { subject }.to raise_error(
              CustomExceptionOnValueValidation,
              'Error on custom exception'
            )
          end
        end
      end
    end

    context 'when only the max is set' do
      let(:max) { 1_000 }

      let(:key_value) { rand(0..1_000) }

      it { expect(response).to have_http_status(200) }

      context 'when parameter value is invalid' do
        let(:key_value) { rand(1_001..100_000_000) }

        it { expect(response).to have_http_status(422) }

        it 'returns the correct error message' do
          expect(response.body).to eq(
            build_error_response(
              :invalid_param,
              param_key: :key, details: "Value should be less or equal than #{max}"
            )
          )
        end

        context 'when the message option is set' do
          let(:message) { 'My custom message' }

          it 'returns the correct error message' do
            expect(response.body).to eq(
              build_error_response(:invalid_param, param_key: :key, details: message)
            )
          end

          it_behaves_like 'an element of an array with value error'
        end

        it_behaves_like 'an element of an array with value error'
      end
    end

    context 'when the min and max options are set' do
      let(:min) { 500}
      let(:max) { 1_000 }

      let(:key_value) { rand(500..1_000) }

      it { expect(response).to have_http_status(200) }

      context 'when parameter value is invalid' do
        let(:key_value) { [rand(0..499), rand(1_001..100_000_000)].sample }

        it { expect(response).to have_http_status(422) }

        it 'returns the correct error message' do
          expect(response.body).to eq(
            build_error_response(
              :invalid_param,
              param_key: :key, details: "Value should be between #{min} and #{max}"
            )
          )
        end

        context 'when the message option is set' do
          let(:message) { 'My custom message' }

          it 'returns the correct error message' do
            expect(response.body).to eq(
              build_error_response(:invalid_param, param_key: :key, details: message)
            )
          end

          it_behaves_like 'an element of an array with value error'
        end

        it_behaves_like 'an element of an array with value error'
      end
    end
  end
end

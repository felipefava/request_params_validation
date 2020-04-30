require_relative '../../shared/element_of_an_array_with_error'

RSpec.shared_examples 'validates format' do
  describe 'format validator' do
    let(:message) { nil }
    let(:define_params) { -> (params) { params.optional :key, format: format } }

    let(:request_params) { { key: key_value } }

    before { post :dummy, body: request_params.to_json, as: :json rescue nil }

    context 'when format option is a regexp' do
      let(:format) { /^start .* end$/ }

      let(:key_value) { 'start some-value end' }

      it { expect(response).to have_http_status(200) }

      context 'when parameter value is invalid' do
        let(:key_value) { 'invalid value' }

        it { expect(response).to have_http_status(422) }

        it 'returns the correct error message' do
          expect(response.body).to eq(
            build_error_response(
              :invalid_param,
              param_key: :key, details: 'Value format is invalid'
            )
          )
        end

        it_behaves_like 'an element of an array with format error'

        describe 'custom exception for format validations' do
          class CustomExceptionOnFormatValidation < StandardError
            def initialize(_options)
              super('Error on custom exception')
            end
          end

          let(:exception_on_invalid_parameter_format) { CustomExceptionOnFormatValidation }

          subject { post :dummy, body: request_params.to_json, as: :json }

          it 'calls the exception with the right parameters' do
            expect(CustomExceptionOnFormatValidation).to receive(:new).with(
              param_key: :key,
              param_type: nil,
              param_value: key_value,
              regexp: format,
              details: 'Value format is invalid'
            )

            subject rescue nil
          end

          it 'raises the right exception' do
            expect { subject }.to raise_error(
              CustomExceptionOnFormatValidation,
              'Error on custom exception'
            )
          end
        end
      end
    end

    context 'when format option is a hash' do
      let(:regexp) { /^1.*/ }
      let(:format) { { regexp: regexp, message: message } }

      let(:key_value) { '1 some value' }

      it { expect(response).to have_http_status(200) }

      context 'when parameter value is invalid' do
        let(:key_value) { 'do not start with 1' }

        it { expect(response).to have_http_status(422) }

        it 'returns the correct error message' do
          expect(response.body).to eq(
            build_error_response(
              :invalid_param,
              param_key: :key, details: 'Value format is invalid'
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

          it_behaves_like 'an element of an array with format error'
        end

        it_behaves_like 'an element of an array with format error'
      end
    end
  end
end

require_relative '../../shared/element_of_an_array_with_error'

RSpec.shared_examples 'validates inclusion' do
  describe 'inclusion validator' do
    let(:message) { nil }
    let(:define_params) { -> (params) { params.optional :key, inclusion: inclusion } }

    let(:request_params) { { key: key_value } }

    before { post :dummy, body: request_params.to_json, as: :json rescue nil }

    context 'when inclusion option is an array' do
      let(:include_in) { [1, 'some value', false] }
      let(:inclusion) { include_in }

      let(:key_value) { inclusion.sample }

      it { expect(response).to have_http_status(200) }

      context 'when parameter value is invalid' do
        let(:key_value) { [2, 'another value', true].sample }

        it { expect(response).to have_http_status(422) }

        it 'returns the correct error message' do
          expect(response.body).to eq(
            build_error_response(
              :invalid_param,
              param_key: :key, details: "Value should be in #{inclusion}"
            )
          )
        end

        it_behaves_like 'an element of an array with inclusion error'

        describe 'custom exception for inclusion validations' do
          class CustomExceptionOnInclusionValidation < StandardError
            def initialize(_options)
              super('Error on custom exception')
            end
          end

          let(:exception_on_invalid_parameter_inclusion) { CustomExceptionOnInclusionValidation }

          subject { post :dummy, body: request_params.to_json, as: :json }

          it 'calls the exception with the right parameters' do
            expect(CustomExceptionOnInclusionValidation).to receive(:new).with(
              param_key: :key,
              param_type: nil,
              param_value: key_value,
              include_in: include_in,
              details: "Value should be in #{inclusion}"
            )

            subject rescue nil
          end

          it 'raises the right exception' do
            expect { subject }.to raise_error(
              CustomExceptionOnInclusionValidation,
              'Error on custom exception'
            )
          end
        end
      end
    end

    context 'when inclusion option is a hash' do
      let(:include_in) { [1, 2, 3, 4, 5] }
      let(:inclusion) { { in: include_in, message: message } }

      let(:key_value) { inclusion[:in].sample }

      it { expect(response).to have_http_status(200) }

      context 'when parameter value is invalid' do
        let(:key_value) { 0 }

        it { expect(response).to have_http_status(422) }

        it 'returns the correct error message' do
          expect(response.body).to eq(
            build_error_response(
              :invalid_param,
              param_key: :key, details: "Value should be in #{include_in}"
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

          it_behaves_like 'an element of an array with inclusion error'
        end

        it_behaves_like 'an element of an array with inclusion error'
      end
    end
  end
end

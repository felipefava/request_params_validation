require_relative '../../shared/element_of_an_array_with_error'

RSpec.shared_examples 'validates length' do
  describe 'length validator' do
    let(:message) { nil }
    let(:define_params) { -> (params) { params.optional :key, length: length } }

    let(:request_params) { { key: key_value } }

    before { post :dummy, body: request_params.to_json, as: :json rescue nil }

    context 'when length option is an integer' do
      let(:min) { 4 }
      let(:max) { 4 }
      let(:length) { 4 }

      let(:key_value) { ['some', [1, 2, 3, 4], '4444'].sample }

      it { expect(response).to have_http_status(200) }

      context 'when parameter value is invalid' do
        let(:key_value) { ['long value', 'sho', [1, 2]].sample }

        it { expect(response).to have_http_status(422) }

        it 'returns the correct error message' do
          expect(response.body).to eq(
            build_error_response(
              :invalid_param,
              param_key: :key, details: "Length should be equal to #{length}"
            )
          )
        end

        it_behaves_like 'an element of an array with length error'

        describe 'custom exception for length validations' do
          class CustomExceptionOnLengthValidation < StandardError
            def initialize(options)
              super('Error on custom exception')
            end
          end

          let(:exception_on_invalid_parameter_length) { CustomExceptionOnLengthValidation }

          subject { post :dummy, body: request_params.to_json, as: :json }

          it 'calls the exception with the right parameters' do
            expect(CustomExceptionOnLengthValidation).to receive(:new).with(
              param_key: :key,
              param_type: nil,
              param_value: key_value,
              min: min,
              max: max,
              details: "Length should be equal to #{length}"
            )

            subject rescue nil
          end

          it 'raises the right exception' do
            expect { subject }.to raise_error(
              CustomExceptionOnLengthValidation,
              'Error on custom exception'
            )
          end
        end
      end
    end

    context 'when length option is a hash' do
      let(:min) { nil }
      let(:max) { nil }
      let(:length) { { min: min, max: max, message: message } }

      context 'when only the min option is set' do
        let(:min) { 2 }

        let(:key_value) { ['..', [1, 2, 3, 4], :longer_symbol].sample }

        it { expect(response).to have_http_status(200) }

        context 'when parameter value is invalid' do
          let(:key_value) { ['.', [], '1'].sample }

          it { expect(response).to have_http_status(422) }

          it 'returns the correct error message' do
            expect(response.body).to eq(
              build_error_response(
                :invalid_param,
                param_key: :key, details: "Length should be greater or equal than #{min}"
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

            it_behaves_like 'an element of an array with length error'
          end

          it_behaves_like 'an element of an array with length error'
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
            expect(response.body).to eq(
              build_error_response(
                :invalid_param,
                param_key: :key, details: "Length should be less or equal than #{max}"
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

            it_behaves_like 'an element of an array with length error'
          end

          it_behaves_like 'an element of an array with length error'
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
            expect(response.body).to eq(
              build_error_response(
                :invalid_param,
                param_key: :key, details: "Length should be between #{min} and #{max}"
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

            it_behaves_like 'an element of an array with length error'
          end

          it_behaves_like 'an element of an array with length error'
        end
      end
    end
  end
end

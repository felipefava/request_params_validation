RSpec.shared_examples 'validates presence' do
  describe 'presence validator' do
    let(:request_params) { { key: key_value } }

    before { post :dummy, body: request_params.to_json, as: :json rescue nil }

    context 'when the parameter is optional' do
      let(:define_params) { -> (params) { params.optional :key } }

      let(:key_value) { 'some value' }

      it { expect(response).to have_http_status(200) }

      context 'when parameter value is not present' do
        let(:key_value) { [nil, '', {}, []].sample }

        it { expect(response).to have_http_status(200) }
      end
    end

    context 'when parameter is required' do
      let(:allow_blank) { [false, nil].sample }
      let(:define_params) { -> (params) { params.required :key, allow_blank: allow_blank } }

      let(:key_value) { 'some value' }

      it { expect(response).to have_http_status(200) }

      context 'when parameter value is not present' do
        let(:key_value) { [nil, '', {}, []].sample }

        it { expect(response).to have_http_status(422) }

        it 'returns the correct error message' do
          expect(response.body).to eq(build_error_response(:missing_param, param_key: :key))
        end

        context 'when parameter value is false' do
          let(:key_value) { false }

          it { expect(response).to have_http_status(200) }
        end

        describe 'custom exception for presence validations' do
          class CustomExceptionOnPresenceValidation < StandardError
            def initialize(_options)
              super('Error on custom exception')
            end
          end

          let(:exception_on_missing_parameter) { CustomExceptionOnPresenceValidation }

          subject { post :dummy, body: request_params.to_json, as: :json }

          it 'calls the exception with the right parameters' do
            expect(CustomExceptionOnPresenceValidation).to receive(:new).with(
              param_key: :key,
              param_type: nil,
              param_value: key_value
            )

            subject rescue nil
          end

          it 'raises the right exception' do
            expect { subject }.to raise_error(
              CustomExceptionOnPresenceValidation,
              'Error on custom exception'
            )
          end
        end
      end

      context 'when allow blank option is true' do
        let(:allow_blank) { true }

        it { expect(response).to have_http_status(200) }

        context 'when parameter value is empty' do
          let(:key_value) { ['', {}, []].sample }

          it { expect(response).to have_http_status(200) }
        end

        context 'when parameter value is nil' do
          let(:key_value) { nil }

          it { expect(response).to have_http_status(422) }

          it 'returns the correct error message' do
            expect(response.body).to eq(build_error_response(:missing_param, param_key: :key))
          end
        end
      end
    end
  end
end

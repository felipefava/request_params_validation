require_relative '../../shared/element_of_an_array_with_error'

RSpec.shared_examples 'validates inclusion' do
  describe 'inclusion validator' do
    let(:message) { nil }
    let(:define_params) { -> (params) { params.optional :key, inclusion: inclusion } }

    let(:request_params) { { key: key_value } }

    before { post :dummy, body: request_params.to_json, as: :json }

    context 'when inclusion option is an array' do
      let(:inclusion_in) { [1, 'some value', false] }
      let(:inclusion) { inclusion_in }

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
      end
    end

    context 'when inclusion option is a hash' do
      let(:inclusion_in) { [1, 2, 3, 4, 5] }
      let(:inclusion) { { in: inclusion_in, message: message } }

      let(:key_value) { inclusion[:in].sample }

      it { expect(response).to have_http_status(200) }

      context 'when parameter value is invalid' do
        let(:key_value) { 0 }

        it { expect(response).to have_http_status(422) }

        it 'returns the correct error message' do
          expect(response.body).to eq(
            build_error_response(
              :invalid_param,
              param_key: :key, details: "Value should be in #{inclusion_in}"
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

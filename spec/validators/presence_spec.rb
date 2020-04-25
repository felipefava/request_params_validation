RSpec.shared_examples 'validates presence' do
  describe 'presence validator' do
    let(:request_params) { { key: key_value } }

    before { post :dummy, body: request_params.to_json, as: :json }

    context 'when param is optional' do
      let(:define_params) { -> (params) { params.optional :key } }

      context 'and value is present' do
        let(:key_value) { 'some value' }

        it { expect(response).to have_http_status(200) }
      end

      context "and value is not present" do
        let(:key_value) { [nil, '', {}, []].sample }

        it { expect(response).to have_http_status(200) }
      end
    end

    context 'when param is required' do
      let(:define_params) { -> (params) { params.required :key } }

      context 'and value is present' do
        let(:key_value) { 'some value' }

        it { expect(response).to have_http_status(200) }
      end

      context 'and value is not present' do
        let(:key_value) { [nil, '', {}, []].sample }

        it { expect(response).to have_http_status(422) }

        it 'has the correct error messages' do
          expect(response.body).to eq({
            status: :error,
            key: 'RequestParamsValidation::MissingParameterError',
            message: "The parameter 'key' is missing"
          }.to_json)
        end
      end
    end

    context 'when param is required but allows blank values' do
      let(:define_params) { -> (params) { params.required :key, allow_blank: true } }

      context 'and value is present' do
        let(:key_value) { 'some value' }

        it { expect(response).to have_http_status(200) }
      end

      context 'and value is empty' do
        let(:key_value) { ['', {}, []].sample }

        it { expect(response).to have_http_status(200) }
      end

      context 'and value is nil' do
        let(:key_value) { nil }

        it { expect(response).to have_http_status(422) }

        it 'has the correct error messages' do
          expect(response.body).to eq({
            status: :error,
            key: 'RequestParamsValidation::MissingParameterError',
            message: "The parameter 'key' is missing"
          }.to_json)
        end
      end
    end
  end
end

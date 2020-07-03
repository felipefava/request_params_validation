RSpec.describe ApplicationController, type: :controller  do
  describe 'if_given option' do
    let(:define_params) do
      lambda do |params|
        params.optional :key_1, as: key_1_rename
        params.required :key_2, if_given: if_given_option
      end
    end

    let(:if_given_option) { :key_1 }
    let(:key_1_rename) { nil }

    let(:key_1_value) { 'key 1 value' }
    let(:key_2_value) { 'key 2 value' }

    let(:request_params) { { key_1: key_1_value, key_2: key_2_value } }

    before { post :dummy, body: request_params.to_json, as: :json }

    it { expect(controller.params[:key_1]).to eq(key_1_value) }
    it { expect(controller.params[:key_2]).to eq(key_2_value) }

    context 'when key_2 is not present' do
      let(:key_2_value) { [nil, ''].sample }

      it 'returns the correct error message' do
        expect(response.body).to eq(build_error_response(:missing_param, param_key: :key_2))
      end
    end

    context 'when key_1 is not present' do
      let(:key_1_value) { [nil, ''].sample }

      it { expect(controller.params[:key_1]).to eq(key_1_value) }
      it { expect(controller.params.key?(:key_2)).to eq(false) }

      context 'when key_2 is not present' do
        let(:key_2_value) { [nil, ''].sample }

        it { expect(controller.params[:key_1]).to eq(key_1_value) }
        it { expect(controller.params.key?(:key_2)).to eq(false) }
      end
    end

    context 'when key_1 has been renamed' do
      let(:key_1_rename) { :renamed_key_1 }

      it { expect(controller.params[:renamed_key_1]).to eq(key_1_value) }
      it { expect(controller.params.key?(:key_2)).to eq(false) }

      context 'when if_given_option matches with the renamed key' do
        let(:if_given_option) { :renamed_key_1 }

        it { expect(controller.params[:renamed_key_1]).to eq(key_1_value) }
        it { expect(controller.params[:key_2]).to eq(key_2_value) }
      end
    end

    context 'when if_given_option has custom matcher' do
      let(:if_given_option) { { key_1: -> (val) { val == 'expected value' } } }

      let(:key_1_value) { 'expected value' }

      it { expect(controller.params[:key_1]).to eq(key_1_value) }
      it { expect(controller.params[:key_2]).to eq(key_2_value) }

      context 'when key_2 is not present' do
        let(:key_2_value) { [nil, ''].sample }

        it 'returns the correct error message' do
          expect(response.body).to eq(build_error_response(:missing_param, param_key: :key_2))
        end
      end

      context 'when key_1 has not the expected value of the option if_given' do
        let(:key_1_value) { 'not expected value' }

        it { expect(controller.params[:key_1]).to eq(key_1_value) }
        it { expect(controller.params.key?(:key_2)).to eq(false) }

        context 'when key_2 is not present' do
          it { expect(controller.params[:key_1]).to eq(key_1_value) }
          it { expect(controller.params.key?(:key_2)).to eq(false) }
        end
      end
    end
  end
end

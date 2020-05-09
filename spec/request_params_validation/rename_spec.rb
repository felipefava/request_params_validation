RSpec.describe ApplicationController, type: :controller  do
  describe 'rename params' do
    let(:define_params) do
      lambda do |params|
        params.required :key, as: new_name
      end
    end

    let(:param_value) { 'some awesome value' }
    let(:new_name) { 'rename_key' }

    let(:request_params) { { key: param_value } }

    before { post :dummy, body: request_params.to_json, as: :json }

    it { expect(controller.params[new_name]).to eq(param_value) }
    it { expect(controller.params[:key]).to eq(nil) }

    context "when 'as' option is not set" do
      let(:new_name) { nil }

      it { expect(controller.params[:key]).to eq(param_value) }
    end
  end
end

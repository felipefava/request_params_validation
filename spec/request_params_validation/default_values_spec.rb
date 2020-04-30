RSpec.describe ApplicationController, type: :controller  do
  describe 'params default values' do
    let(:define_params) do
      lambda do |params|
        params.optional :no_default
        params.optional :default_value, default: 'Default optional'
        params.optional :default_proc, default: -> () { [Time.now] }
      end
    end

    let(:request_params) { {} }

    before do
      allow(Time).to receive(:now).and_return(Time.now)
      post :dummy, body: request_params.to_json, as: :json
    end

    it { expect(controller.params[:no_default]).to eq(nil) }
    it { expect(controller.params[:default_value]).to eq('Default optional') }
    it { expect(controller.params[:default_proc]).to eq([Time.now]) }

    context 'when params are blank' do
      let(:request_params) { { no_default: '', default_value: '', default_proc: [] } }

      it { expect(controller.params[:no_default]).to eq('') }
      it { expect(controller.params[:default_value]).to eq('Default optional') }
      it { expect(controller.params[:default_proc]).to eq([Time.now]) }
    end
  end
end

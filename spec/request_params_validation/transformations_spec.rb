RSpec.describe ApplicationController, type: :controller  do
  describe 'params transformations' do
    let(:define_params) do
      -> (params) do
        params.required :no_transform
        params.required :transform_1, type: :string, transform: :strip
        params.required :transform_2, type: :integer, transform: -> (value) { value * 10 }
      end
    end

    let(:request_params) do
      {
        no_transform: 'no transform  ',
        transform_1: 'transform 1    ',
        transform_2: '100'
      }
    end

    before { post :dummy, body: request_params.to_json, as: :json }

    it { expect(controller.params[:no_transform]).to eq('no transform  ') }
    it { expect(controller.params[:transform_1]).to eq('transform 1') }
    it { expect(controller.params[:transform_2]).to eq(1_000) }
  end
end

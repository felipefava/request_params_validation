RSpec.describe ApplicationController, type: :controller  do
  describe 'global configurations' do
    describe 'helper_method_name' do
      let(:define_params) { -> (params) {} }

      let(:helper_method_name) { :validate_request_parameters }

      before {
        reload('lib/request_params_validation/helpers')
        post :dummy, body: {}.to_json, as: :json
      }

      it { expect(controller.methods).to include(:validate_request_parameters) }
    end

    describe 'on_definition_not_found' do
      subject { post :dummy_with_no_definition, body: {}.to_json, as: :json }

      it { expect { subject }.not_to raise_error }

      context 'when is set to raise' do
        let(:on_definition_not_found) { :raise }

        it 'raises RequestParamsValidation::DefinitionNotFoundError' do
          expect { subject }.to raise_error(
            RequestParamsValidation::DefinitionNotFoundError,
            "The request definition for the resource 'application' and " \
            "action 'dummy_with_no_definition' couldn't be found"
          )
        end
      end
    end

    describe 'save_original_params' do
      let(:define_params) { -> (params) { params.optional :optional_key, default: 'hi' } }

      let(:save_original_params) { :@original_params }

      let(:request_params) { { key: 'value' } }
      let(:expected_params) { { optional_key: 'hi', controller: 'application', action: 'dummy' } }

      before { post :dummy, body: request_params.to_json, as: :json }

      it { expect(controller.params).to be_hash_with_value(expected_params) }

      it 'saves the original params' do
        expect(
          controller.instance_variable_get(:@original_params).to_unsafe_h
        ).to include(request_params)
      end
    end
  end
end

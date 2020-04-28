RSpec.shared_examples 'definitions' do
  let(:define_params) { -> (params) {} }

  describe 'definitions hash' do
    subject { RequestParamsValidation::Definitions.class_variable_get(:@@definitions) }

    let(:definitions) { ['application', 'some_other'] }
    let(:application_definition_actions) { ['dummy'] }
    let(:some_other_definition_actions) do
      ['another_action_1', 'another_action_2', 'another_action_3']
    end

    it { expect(subject.keys).to match_array(definitions) }

    it { expect(subject['application'].actions.keys).to match_array(application_definition_actions) }

    it { expect(subject['some_other'].actions.keys).to match_array(some_other_definition_actions) }

    context 'when definitions_path option is set' do
      let(:definitions_path) { :definitions }

      let(:definitions) { ['test_path'] }
      let(:test_path_actions) { ['path_action_1', 'path_action_2'] }

      it { expect(subject.keys).to match_array(definitions) }

      it { expect(subject['test_path'].actions.keys).to match_array(test_path_actions) }

      context 'when it starts with a /' do
        let(:definitions_path) { '/definitions' }

        it { expect(subject.keys).to match_array(definitions) }

        it { expect(subject['test_path'].actions.keys).to match_array(test_path_actions) }
      end

      context 'when it ends with a /' do
        let(:definitions_path) { 'definitions/' }

        it { expect(subject.keys).to match_array(definitions) }

        it { expect(subject['test_path'].actions.keys).to match_array(test_path_actions) }
      end
    end

    context 'when definitions_suffix option is set' do
      let(:definitions_path) { :definitions }
      let(:definitions_suffix) { :_custom }

      let(:definitions) { ['test_suffix'] }
      let(:test_definition_actions) { ['suffix_action_1', 'suffix_action_2'] }

      it { expect(subject.keys).to match_array(definitions) }

      it { expect(subject['test_suffix'].actions.keys).to match_array(test_definition_actions) }
    end
  end

  describe 'definitions with errors' do
    let(:definitions_path) { :definitions }

    subject { load "#{Rails.root}/definitions/#{resource}.rb" }

    context 'when the resource definitino has the error' do
      let(:resource) { 'test_with_resource_error' }

      it 'raises RequestParamsValidation::DefinitionArgumentError' do
        expect { subject }.to raise_error(
          RequestParamsValidation::DefinitionArgumentError,
          'Expecting block for resource definition'
        )
      end
    end

    context 'when the action definition has the error' do
      let(:resource) { 'test_with_action_error' }

      it 'raises RequestParamsValidation::DefinitionArgumentError' do
        expect { subject }.to raise_error(
          RequestParamsValidation::DefinitionArgumentError,
          "Argument error for resource 'test_with_action_error'. " \
          "Expecting block for action 'action_with_no_block'"
        )
      end
    end
  end

  describe 'get definition request' do
    let(:resource) { 'application' }
    let(:action) { 'dummy' }

    subject { RequestParamsValidation::Definitions.get_request(resource, action) }

    it { expect(subject).to be_a(RequestParamsValidation::Definitions::Request) }

    context 'when action definition does not exist' do
      let(:action) { 'non_existance' }

      it { expect(subject).to eq(nil) }
    end

    context 'when resource definition does not exist' do
      let(:resource) { 'non_existance' }

      it { expect(subject).to eq(nil) }
    end
  end
end

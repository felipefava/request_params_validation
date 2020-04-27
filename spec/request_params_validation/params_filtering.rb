RSpec.shared_examples 'filter params' do
  describe 'filtering' do
    let(:filter_params) { true }
    let(:remove_keys_from_params) { [] }

    let(:define_params) do
      -> (params) do
        params.required :key_1
        params.required :key_2, type: :hash
        params.required :key_3, type: :array

        params.required :key_4, type: :array, elements: :hash do |key_4|
          key_4.required :key_4__1
          key_4.required :key_4__2
        end

        params.required :key_5, type: :hash do |key_5|
          key_5.required :key_5__1
          key_5.required :key_5__2
          key_5.required :key_5__3
        end
      end
    end

    let(:request_params) do
      {
        key_1: 'some value',
        key_2: {
          key_2__anything_1: 500,
          key_2__anything_2: [1, 2, 3],
          key_2__anything_2: { a: 2 }
        },
        key_3: ['element', 1_000, [], {}],
        key_4: [
          {
            key_4__1: 'key_4__1',
            key_4__2: 'key_4__2',
            extra_key: 'extra_key'
          },
          {
            key_4__1: 'key_4__1',
            key_4__2: 'key_4__2',
            extra_key: 'extra_key'
          },
          {
            key_4__1: 'key_4__1',
            key_4__2: 'key_4__2',
            extra_key: 'extra_key',
            another_extra_key: 'another_extra_key'
          }
        ],
        key_5: {
          key_5__1: 'key_5__1',
          key_5__2: 'key_5__2',
          key_5__3: 'key_5__3',
          extra_key: 'extra_key',
          another_extra_key: 'another_extra_key'
        },
        extra_key: 'extra_key',
        another_extra_key: 'another_extra_key'
      }
    end

    let(:expected_params) do
      {
        key_1: 'some value',
        key_2: {
          key_2__anything_1: 500,
          key_2__anything_2: [1, 2, 3],
          key_2__anything_2: { a: 2 }
        },
        key_3: ['element', 1_000, [], {}],
        key_4: [
          {
            key_4__1: 'key_4__1',
            key_4__2: 'key_4__2'
          },
          {
            key_4__1: 'key_4__1',
            key_4__2: 'key_4__2'
          },
          {
            key_4__1: 'key_4__1',
            key_4__2: 'key_4__2'
          }
        ],
        key_5: {
          key_5__1: 'key_5__1',
          key_5__2: 'key_5__2',
          key_5__3: 'key_5__3'
        },
        controller: 'application',
        action: 'dummy'
      }
    end

    before { post :dummy, body: request_params.to_json, as: :json }

    it { expect(controller.params).to be_hash_with_value(expected_params) }

    it { expect(controller.params.permitted?).to eq(true) }

    context 'when global option remove_keys_from_params is set' do
      let(:remove_keys_from_params) { [:controller, :action] }

      before { expected_params.except!(*remove_keys_from_params)}

      it { expect(controller.params).to be_hash_with_value(expected_params) }
    end

    context 'when global option filter_params is disabled' do
      let(:filter_params) { false }

      it 'does not filter the original params' do
        expect(controller.params.to_unsafe_h).to include(request_params)
      end

      it { expect(controller.params.permitted?).to eq(false) }
    end
  end
end

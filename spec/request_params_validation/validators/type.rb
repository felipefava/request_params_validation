require_relative '../../shared/element_of_an_array_with_error'

RSpec.shared_examples 'validates type' do
  describe 'type validator' do
    let(:format) { nil }
    let(:define_params) { -> (params) { params.optional :key, type: key_type, format: format } }

    let(:request_params) { { key: key_value } }

    before { post :dummy, body: request_params.to_json, as: :json rescue nil }

    context 'when type is string' do
      let(:key_type) { [:string, 'string'].sample }

      let(:key_value) { ['some value', rand(1_000), [:element], { a: rand(1_000) }, true].sample }

      it 'any value is valid' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when type is array' do
      let(:key_type) { [:array, 'array'].sample }

      let(:key_value) { [rand(1_000), :john, 'Doe', false] }

      it { expect(response).to have_http_status(200) }

      context 'when parameter value is not a valid array' do
        let(:key_value) { [rand(1_000), :john, 'Doe', false].sample }

        it { expect(response).to have_http_status(422) }

        it 'returns the correct error message' do
          expect(response.body).to eq(
            build_error_response(
              :invalid_param,
              param_key: :key, details: "Value should be a valid array"
            )
          )
        end

        it_behaves_like 'an element of an array with type error'
      end
    end

    context 'when type is hash' do
      let(:key_type) { [:hash, 'hash'].sample }

      let(:key_value) { { a: rand(1_000), b: [1, 2, 3], c: 'Im c key' } }

      it { expect(response).to have_http_status(200) }

      context 'when parameter value is not a valid hash' do
        let(:key_value) { [rand(1_000), :john, 'Doe', false, [1, 2, 3]].sample }

        it { expect(response).to have_http_status(422) }

        it 'returns the correct error message' do
          expect(response.body).to eq(
            build_error_response(
              :invalid_param,
              param_key: :key, details: "Value should be a valid object"
            )
          )
        end

        it_behaves_like 'an element of an array with type error', :object
      end
    end

    context 'when type is integer' do
      let(:key_type) { [:integer, 'integer'].sample }

      let(:key_value) { [rand(1_000), rand(1_000).to_s].sample }

      it { expect(response).to have_http_status(200) }

      context 'when parameter value is not a valid integer' do
        let(:key_value) { [rand(0.0..1_000.0), '1.5', 'Doe', false, [1, 2, 3]].sample }

        it { expect(response).to have_http_status(422) }

        it 'returns the correct error message' do
          expect(response.body).to eq(
            build_error_response(
              :invalid_param,
              param_key: :key, details: "Value should be a valid integer"
            )
          )
        end

        it_behaves_like 'an element of an array with type error'
      end
    end

    context 'when type is decimal' do
      let(:key_type) { [:decimal, 'decimal'].sample }

      let(:key_value) do
        [rand(1_000), rand(1_000).to_s, rand(0.0..1_000.0), rand(0.0..1_000.0).to_s].sample
      end

      it { expect(response).to have_http_status(200) }

      context 'when parameter value is not a valid decimal' do
        let(:key_value) { ['199.0a', '0,981', 'Doe', false, [1, 2, 3]].sample }

        it { expect(response).to have_http_status(422) }

        it 'returns the correct error message' do
          expect(response.body).to eq(
            build_error_response(
              :invalid_param,
              param_key: :key, details: "Value should be a valid decimal"
            )
          )
        end

        it_behaves_like 'an element of an array with type error'
      end
    end

    context 'when type is date' do
      let(:key_type) { [:date, 'date'].sample }

      let(:key_value) { Date.today.to_s }

      it { expect(response).to have_http_status(200) }

      context 'when parameter value is not a valid date' do
        let(:key_value) { [rand(1_000), [1, 2, 3], true, '2019/33/33'].sample }

        it { expect(response).to have_http_status(422) }

        it 'returns the correct error message' do
          expect(response.body).to eq(
            build_error_response(
              :invalid_param,
              param_key: :key, details: "Value should be a valid date"
            )
          )
        end

        it_behaves_like 'an element of an array with type error'
      end

      context 'when the format option is set as string' do
        let(:format) { '%Y/%m/%e' }

        let(:key_value) { '2019/04/11' }

        it { expect(response).to have_http_status(200) }

        context 'when parameter value has the wrong format' do
          let(:key_value) { '2019-04-11' }

          it { expect(response).to have_http_status(422) }

          it 'returns the correct error message' do
            expect(response.body).to eq(
              build_error_response(
                :invalid_param,
                param_key: :key, details: "Value should be a valid date with the format #{format}"
              )
            )
          end
        end
      end

      context 'when the format option is set as hash' do
        let(:message) { nil }
        let(:format) { { strptime: '%Y/%m/%e', message: message } }

        let(:key_value) { '2019/04/11' }

        it { expect(response).to have_http_status(200) }

        context 'when parameter value has the wrong format' do
          let(:key_value) { '2019-04-11' }

          it { expect(response).to have_http_status(422) }

          it 'returns the correct error message' do
            expect(response.body).to eq(
              build_error_response(
                :invalid_param,
                param_key: :key,
                details: "Value should be a valid date with the format #{format[:strptime]}"
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
          end
        end
      end
    end

    context 'when type is datetime' do
      let(:key_type) { [:datetime, 'datetime'].sample }

      let(:key_value) { DateTime.now.to_s }

      it { expect(response).to have_http_status(200) }

      context 'when parameter value is not a valid datetime' do
        let(:key_value) { [rand(1_000), [1, 2, 3], true, '2020-04-01T26:02:56'].sample }

        it { expect(response).to have_http_status(422) }

        it 'returns the correct error message' do
          expect(response.body).to eq(
            build_error_response(
              :invalid_param,
              param_key: :key,
              details: "Value should be a valid datetime"
            )
          )
        end

        it_behaves_like 'an element of an array with type error'
      end

      context 'when the format option is set as string' do
        let(:format) { '%Y/%m/%e %H:%M' }

        let(:key_value) { '2019/04/11 19:03' }

        it { expect(response).to have_http_status(200) }

        context 'when paramater value has the wrong format' do
          let(:key_value) { '2019/04/11 - 19:03' }

          it { expect(response).to have_http_status(422) }

          it 'returns the correct error message' do
            expect(response.body).to eq(
              build_error_response(
                :invalid_param,
                param_key: :key,
                details: "Value should be a valid datetime with the format #{format}"
              )
            )
          end
        end
      end

      context 'when the format option is set as hash' do
        let(:message) { nil }
        let(:format) { { strptime: '%Y/%m/%e %H:%M', message: message } }

        let(:key_value) { '2019/04/11 19:03' }

        it { expect(response).to have_http_status(200) }

        context 'when parameter value has the wrong format' do
          let(:key_value) { '2019/04/11 - 19:03' }

          it { expect(response).to have_http_status(422) }

          it 'returns the correct error message' do
            expect(response.body).to eq(
              build_error_response(
                :invalid_param,
                param_key: :key,
                details: "Value should be a valid datetime with the format #{format[:strptime]}"
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
          end
        end
      end
    end

    context 'when type is boolean' do
      let(:key_type) { [:boolean, 'boolean'].sample }

      let(:key_value) { [true, false, 'true', 'false'].sample }

      it { expect(response).to have_http_status(200) }

      context 'when parameter value is not a valid boolean' do
        let(:key_value) { [rand(1_000), 'truthy', 'falsey'].sample }

        it { expect(response).to have_http_status(422) }

        it 'returns the correct error message' do
          expect(response.body).to eq(
            build_error_response(
              :invalid_param,
              param_key: :key,
              details: "Value should be a valid boolean"
            )
          )
        end

        it_behaves_like 'an element of an array with type error'
      end
    end

    context 'when type is email' do
      let(:key_type) { [:email, 'email'].sample }

      let(:key_value) { 'john.doe@email.com' }

      it { expect(response).to have_http_status(200) }

      context 'when parameter value is not a valid email' do
        let(:key_value) { 'john.doe@email.' }

        it { expect(response).to have_http_status(422) }

        it 'returns the correct error message' do
          expect(response.body).to eq(
            build_error_response(
              :invalid_param,
              param_key: :key,
              details: "Value should be a valid email"
            )
          )
        end

        it_behaves_like 'an element of an array with type error'
      end
    end

    context 'when type does not exist' do
      let(:key_type) { 'invalid_type' }

      let(:key_value) { 'anything' }

      it 'raises error' do
        expect {
          post :dummy, body: request_params.to_json, as: :json
        }.to raise_error(
          RequestParamsValidation::UnsupportedTypeError,
          "Unsupported type '#{key_type}' for the parameter 'key'"
        )
      end
    end
  end
end

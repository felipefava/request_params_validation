RSpec.shared_examples 'validates type' do
  describe 'type validator' do
    let(:key_value) { 'anything' }
    let(:request_params) { { key: key_value } }

    let(:format) { nil }
    let(:define_params) { -> (params) { params.optional :key, type: key_type, format: format } }

    before { post :dummy, body: request_params.to_json, as: :json rescue nil }

    context 'when type is string' do
      let(:key_type) { [:string, 'string'].sample }

      context 'and value is anything' do
        let(:key_value) { ['some value', rand(1_000), [:element], { a: rand(1_000) }, true].sample }

        it { expect(response).to have_http_status(200) }
      end
    end

    context 'when type is array' do
      let(:key_type) { [:array, 'array'].sample }

      context 'and value is a valid array' do
        let(:key_value) { [rand(1_000), :john, 'Doe', false] }

        it { expect(response).to have_http_status(200) }
      end

      context 'and value is not a valid array' do
        let(:key_value) { [rand(1_000), :john, 'Doe', false].sample }

        it { expect(response).to have_http_status(422) }

        it 'has the correct error messages' do
          expect(response.body).to eq({
            status: :error,
            key: 'RequestParamsValidation::InvalidParameterValueError',
            message: "The value for the parameter 'key' is invalid. Value should be a valid array"
          }.to_json)
        end
      end
    end

    context 'when type is hash' do
      let(:key_type) { [:hash, 'hash'].sample }

      context 'and value is a valid hash' do
        let(:key_value) { { a: rand(1_000), b: [1,2,3], c: 'Im c key' } }

        it { expect(response).to have_http_status(200) }
      end

      context 'and value is not a valid hash' do
        let(:key_value) { [rand(1_000), :john, 'Doe', false, [1,2,3]].sample }

        it { expect(response).to have_http_status(422) }

        it 'has the correct error messages' do
          expect(response.body).to eq({
            status: :error,
            key: 'RequestParamsValidation::InvalidParameterValueError',
            message: "The value for the parameter 'key' is invalid. Value should be a valid object"
          }.to_json)
        end
      end
    end

    context 'when type is integer' do
      let(:key_type) { [:integer, 'integer'].sample }

      context 'and value is a valid integer' do
        let(:key_value) { [rand(1_000), rand(1_000).to_s].sample }

        it { expect(response).to have_http_status(200) }
      end

      context 'and value is not a valid integer' do
        let(:key_value) { [rand(0.0..1_000.0), '1.0', 'Doe', false, [1,2,3]].sample }

        it { expect(response).to have_http_status(422) }

        it 'has the correct error messages' do
          expect(response.body).to eq({
            status: :error,
            key: 'RequestParamsValidation::InvalidParameterValueError',
            message: "The value for the parameter 'key' is invalid. Value should be a valid integer"
          }.to_json)
        end
      end
    end

    context 'when type is decimal' do
      let(:key_type) { [:decimal, 'decimal'].sample }

      context 'and value is a valid decimal' do
        let(:key_value) do
          [rand(1_000), rand(1_000).to_s, rand(0.0..1_000.0), rand(0.0..1_000.0).to_s].sample
        end

        it { expect(response).to have_http_status(200) }
      end

      context 'and value is not a valid decimal' do
        let(:key_value) { ['199.0a', 'Doe', false, [1,2,3]].sample }

        it { expect(response).to have_http_status(422) }

        it 'has the correct error messages' do
          expect(response.body).to eq({
            status: :error,
            key: 'RequestParamsValidation::InvalidParameterValueError',
            message: "The value for the parameter 'key' is invalid. Value should be a valid decimal"
          }.to_json)
        end
      end
    end

    context 'when type is date' do
      let(:key_type) { [:date, 'date'].sample }

      context 'and value is a valid date' do
        let(:key_value) { Date.today.to_s }

        it { expect(response).to have_http_status(200) }
      end

      context 'and value is not a valid date' do
        let(:key_value) { [rand(1_000), [1,2,3], true, '2019/33/33'].sample }

        it { expect(response).to have_http_status(422) }

        it 'has the correct error messages' do
          expect(response.body).to eq({
            status: :error,
            key: 'RequestParamsValidation::InvalidParameterValueError',
            message: "The value for the parameter 'key' is invalid. Value should be a valid date"
          }.to_json)
        end
      end

      context 'and has defined the format option' do
        let(:format) { '%Y/%m/%e' }

        context 'and value has the right format' do
          let(:key_value) { '2019/04/11' }

          it { expect(response).to have_http_status(200) }
        end

        context 'and value has the wrong format' do
          let(:key_value) { '2019-04-11' }

          it { expect(response).to have_http_status(422) }

          it 'has the correct error messages' do
            expect(response.body).to eq({
              status: :error,
              key: 'RequestParamsValidation::InvalidParameterValueError',
              message: "The value for the parameter 'key' is invalid. Value should be a valid " \
                       "date with the format %Y/%m/%e"
            }.to_json)
          end
        end
      end
    end

    context 'when type is datetime' do
      let(:key_type) { [:datetime, 'datetime'].sample }

      context 'and value is a valid datetime' do
        let(:key_value) { DateTime.now.to_s }

        it { expect(response).to have_http_status(200) }
      end

      context 'and value is not a valid datetime' do
        let(:key_value) { [rand(1_000), [1,2,3], true, '2020-04-01T26:02:56'].sample }

        it { expect(response).to have_http_status(422) }

        it 'has the correct error messages' do
          expect(response.body).to eq({
            status: :error,
            key: 'RequestParamsValidation::InvalidParameterValueError',
            message: "The value for the parameter 'key' is invalid. Value should be a valid datetime"
          }.to_json)
        end
      end

      context 'and has defined the format option' do
        let(:format) { '%Y/%m/%e %H:%M' }

        context 'and value has the right format' do
          let(:key_value) { '2019/04/11 19:03' }

          it { expect(response).to have_http_status(200) }
        end

        context 'and value has the wrong format' do
          let(:key_value) { '2019/04/11 - 19:03' }

          it { expect(response).to have_http_status(422) }

          it 'has the correct error messages' do
            expect(response.body).to eq({
              status: :error,
              key: 'RequestParamsValidation::InvalidParameterValueError',
              message: "The value for the parameter 'key' is invalid. Value should be a valid " \
                       "datetime with the format %Y/%m/%e %H:%M"
            }.to_json)
          end
        end
      end
    end

    context 'when type is boolean' do
      let(:key_type) { [:boolean, 'boolean'].sample }

      context 'and value is a valid boolean' do
        let(:key_value) { [true, false, 'true', 'false'].sample }

        it { expect(response).to have_http_status(200) }
      end

      context 'and value is not a valid boolean' do
        let(:key_value) { [rand(1_000), 'truthy', 'falsey'].sample }

        it { expect(response).to have_http_status(422) }

        it 'has the correct error messages' do
          expect(response.body).to eq({
            status: :error,
            key: 'RequestParamsValidation::InvalidParameterValueError',
            message: "The value for the parameter 'key' is invalid. Value should be a valid boolean"
          }.to_json)
        end
      end
    end

    context 'when type is email' do
      let(:key_type) { [:email, 'email'].sample }

      context 'and value is a valid email' do
        let(:key_value) { 'john.doe@email.com' }

        it { expect(response).to have_http_status(200) }
      end

      context 'and value is not a valid email' do
        let(:key_value) { 'john.doe@email.' }

        it { expect(response).to have_http_status(422) }

        it 'has the correct error messages' do
          expect(response.body).to eq({
            status: :error,
            key: 'RequestParamsValidation::InvalidParameterValueError',
            message: "The value for the parameter 'key' is invalid. Value should be a valid email"
          }.to_json)
        end
      end
    end

    context 'when type does not exist' do
      let(:key_type) { 'custom' }

      it 'raises error' do
        expect{
          post :dummy, body: request_params.to_json, as: :json
        }.to raise_error(
          RequestParamsValidation::UnsupportedTypeError,
          "Unsupported type 'custom' for the parameter 'key'"
        )
      end
    end
  end
end

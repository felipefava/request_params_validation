RSpec.describe ApplicationController, type: :controller  do
  describe 'params coercion' do
    let(:decimal_precision) { nil }
    let(:date_format) { nil }
    let(:datetime_format) { nil }
    let(:array_elements) { nil }

    let(:define_params) do
      lambda do |params|
        params.optional :string, type: :string
        params.optional :integer, type: :integer
        params.optional :decimal, type: :decimal, precision: decimal_precision
        params.optional :date, type: :date, format: date_format
        params.optional :datetime, type: :datetime, format: datetime_format
        params.optional :email, type: :email
        params.optional :array, type: :array, elements: array_elements
        params.optional :hash, type: :hash
      end
    end

    context 'when type is string' do
      def subject(param_value)
        post :dummy, body: { string: param_value }.to_json, as: :json
        controller.params[:string]
      end

      it { expect(subject('A string value')).to be_string_with_value('A string value') }
      it { expect(subject(1_000)).to be_string_with_value('1000') }
      it { expect(subject(999.99)).to be_string_with_value('999.99') }
      it { expect(subject(true)).to be_string_with_value('true') }
      it { expect(subject([1, 2, 3])).to be_string_with_value('[1, 2, 3]') }
      it { expect(subject(a: 25, b: 'b')).to be_string_with_value('{"a"=>25, "b"=>"b"}') }
    end

    context 'when type is integer' do
      def subject(param_value)
        post :dummy, body: { integer: param_value }.to_json, as: :json
        controller.params[:integer]
      end

      it { expect(subject(-50)).to be_integer_with_value(-50) }
      it { expect(subject(0)).to be_integer_with_value(0) }
      it { expect(subject(1_000)).to be_integer_with_value(1_000) }
      it { expect(subject('-99')).to be_integer_with_value(-99) }
      it { expect(subject('-0')).to be_integer_with_value(0) }
      it { expect(subject('158')).to be_integer_with_value(158) }
      it { expect(subject('+200')).to be_integer_with_value(200) }
    end

    context 'when type is decimal' do
      def subject(param_value)
        post :dummy, body: { decimal: param_value }.to_json, as: :json
        controller.params[:decimal]
      end

      it { expect(subject(-50.02)).to be_float_with_value(-50.02) }
      it { expect(subject(0.00)).to be_float_with_value(0) }
      it { expect(subject(500)).to be_float_with_value(500) }
      it { expect(subject(1_000.599)).to be_float_with_value(1_000.599) }
      it { expect(subject('200')).to be_float_with_value(200) }
      it { expect(subject('+158.100')).to be_float_with_value(158.1) }
      it { expect(subject('5000.55')).to be_float_with_value(5000.55) }

      context 'when the precision option is set' do
        let(:decimal_precision) { 3 }

        it { expect(subject(6.2)).to be_float_with_value(6.2) }
        it { expect(subject(0.12321)).to be_float_with_value(0.123) }
        it { expect(subject(100.55268)).to be_float_with_value(100.553) }
        it { expect(subject('0.999999999')).to be_float_with_value(1) }
        it { expect(subject('45')).to be_float_with_value(45.0) }
      end

      context 'when the global format precision is set' do
        let(:format_decimal_precision) { 2 }

        it { expect(subject(0.1291823)).to be_float_with_value(0.13) }
        it { expect(subject(55.55268)).to be_float_with_value(55.55) }

        context 'when local option precision is set' do
          let(:decimal_precision) { 4 }

          it { expect(subject(0.1291823)).to be_float_with_value(0.1292) }
          it { expect(subject(55.55268)).to be_float_with_value(55.5527) }
        end
      end
    end

    context 'when type is date' do
      def subject(param_value)
        post :dummy, body: { date: param_value }.to_json, as: :json
        controller.params[:date]
      end

      it { expect(subject('2020/10/04')).to be_date_with_value(Date.parse('2020/10/04')) }

      context 'when the format option is set' do
        let(:date_format) { '%e %m %Y' }

        it 'coerces to the right date' do
          expect(subject('30 04 1990')).to eq(
            Date.strptime('30 04 1990', date_format)
          )
        end
      end
    end

    context 'when type is datetime' do
      def subject(param_value)
        post :dummy, body: { datetime: param_value }.to_json, as: :json
        controller.params[:datetime]
      end

      it 'coerces to the right datetime' do
        expect(subject('1982/02/09 23:10')).to be_datetime_with_value(
          DateTime.parse('1982/02/09 23:10')
        )
      end

      context 'when the format option is set' do
        let(:datetime_format) { '%d %m %Y - %H:%M' }

        it 'coerces to the right datetime' do
          expect(subject('01 10 2010 - 10:04')).to be_datetime_with_value(
            DateTime.strptime('01 10 2010 - 10:04', datetime_format)
          )
        end
      end
    end

    context 'when type is email' do
      def subject(param_value)
        post :dummy, body: { email: param_value }.to_json, as: :json
        controller.params[:email]
      end

      it { expect(subject('some.one@email.com')).to be_string_with_value('some.one@email.com') }
    end

    context 'when type is array' do
      def subject(param_value)
        post :dummy, body: { array: param_value }.to_json, as: :json
        controller.params[:array]
      end

      it { expect(subject([])).to be_array_with_value([]) }
      it { expect(subject([1, 2, 3, 4])).to be_array_with_value([1, 2, 3, 4]) }
      it { expect(subject([true, 500, 'string'])).to be_array_with_value([true, 500, 'string']) }

      context 'when has definition for the elements of the array' do
        let(:array_elements) { { type: :decimal, precision: 2 } }

        it 'coerces all elements to the right type' do
          expect(subject([100, 25.2501, '300', '595.658', '0.01'])).to eq(
            [100.0, 25.25, 300.0, 595.66, 0.01]
          )
        end
      end
    end

    context 'when type is hash' do
      def subject(param_value)
        post :dummy, body: { hash: param_value }.to_json, as: :json
        controller.params[:hash]
      end

      it { expect(subject({})).to be_hash_with_value({}) }

      it { expect(subject({ a: 100, b: 'b' })).to be_hash_with_value({ a: 100, b: 'b' }) }

      context 'when has nested params' do
        let(:define_params) do
          lambda do |params|
            params.optional :hash, type: :hash do |nested_hash|
              nested_hash.required :nested_key_1, type: :date
              nested_hash.required :nested_key_2, type: :integer
              nested_hash.required :nested_key_3, type: :string
            end
          end
        end

        it 'coerces the nested params to the right type' do
          expect(subject({
            nested_key_1: Time.zone.today.to_s,
            nested_key_2: '200',
            nested_key_3: 'John'
          })).to be_hash_with_value({
            nested_key_1: Time.zone.today,
            nested_key_2: 200,
            nested_key_3: 'John'
          })
        end
      end
    end
  end
end

RSpec.shared_examples 'an element of an array with type error' do |key_type_translation|
  let(:define_params) do
    -> (params) { params.optional :key, type: :array, elements: key_type }
  end

  let(:request_params) { { key: [key_value] } }

  it 'returns the correct error message' do
    expect(response.body).to eq(
      build_error_response(
        :invalid_param,
        param_key: :key,
        details: "All elements of the array should be a valid #{key_type_translation || key_type}"
      )
    )
  end
end

RSpec.shared_examples 'an element of an array with inclusion error' do
  let(:define_params) do
    -> (params) { params.optional :key, type: :array, elements: { inclusion: inclusion } }
  end

  let(:request_params) { { key: [key_value] } }

  it 'returns the correct error message' do
    details = if message
                message
              else
                "All elements values of the array should be in #{inclusion_in}"
              end

    expect(response.body).to eq(
      build_error_response(:invalid_param, param_key: :key, details: details)
    )
  end
end

RSpec.shared_examples 'an element of an array with value error' do
  let(:define_params) do
    -> (params) { params.optional :key, type: :array, elements: { value: value_option } }
  end

  let(:request_params) { { key: [key_value] } }

  it 'returns the correct error message' do
    details = if message
                message
              elsif min && max
                "All elements of the array should have a value between #{min} and #{max}"
              elsif min
                "All elements of the array should have a value greater or equal than #{min}"
              else
                "All elements of the array should have a value less or equal than #{max}"
              end

    expect(response.body).to eq(
      build_error_response(:invalid_param, param_key: :key, details: details)
    )
  end
end

RSpec.shared_examples 'an element of an array with length error' do
  let(:define_params) do
    -> (params) { params.optional :key, type: :array, elements: { length: length } }
  end

  let(:request_params) { { key: [key_value] } }

  it 'returns the correct error message' do
    details = if message
                message
              elsif min && max
                "All elements of the array should have a length " << if min == max
                                                                       "equal to #{max}"
                                                                     else
                                                                       "between #{min} and #{max}"
                                                                     end
              elsif min
                "All elements of the array should have a length greater or equal than #{min}"
              else
                "All elements of the array should have a length less or equal than #{max}"
              end

    expect(response.body).to eq(
      build_error_response(:invalid_param, param_key: :key, details: details)
    )
  end
end

RSpec.shared_examples 'an element of an array with format error' do
  let(:define_params) do
    -> (params) { params.optional :key, type: :array, elements: { format: format } }
  end

  let(:request_params) { { key: [key_value] } }

  it 'returns the correct error message' do
    details = if message
                message
              else
                "An element of the array has an invalid format"
              end

    expect(response.body).to eq(
      build_error_response(:invalid_param, param_key: :key, details: details)
    )
  end
end

RSpec::Matchers.define :be_string_with_value do |value|
  match do |actual|
    expect(actual).to be_a(String)
    expect(actual).to eq(value)
  end
end

RSpec::Matchers.define :be_integer_with_value do |value|
  match do |actual|
    expect(actual).to be_a(Integer)
    expect(actual).to eq(value)
  end
end

RSpec::Matchers.define :be_float_with_value do |value|
  match do |actual|
    expect(actual).to be_a(Float)
    expect(actual).to eq(value)
  end
end

RSpec::Matchers.define :be_date_with_value do |value|
  match do |actual|
    expect(actual).to be_a(Date)
    expect(actual).to eq(value)
  end
end

RSpec::Matchers.define :be_datetime_with_value do |value|
  match do |actual|
    expect(actual).to be_a(DateTime)
    expect(actual).to eq(value)
  end
end

RSpec::Matchers.define :be_array_with_value do |value|
  match do |actual|
    expect(actual).to be_a(Array)
    expect(actual).to eq(value)
  end
end

RSpec::Matchers.define :be_hash_with_value do |value|
  match do |actual|
    expect(actual).to be_a(ActionController::Parameters)
    expect(actual).to eq(ActionController::Parameters.new(value).permit!)
  end
end

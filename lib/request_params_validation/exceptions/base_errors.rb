module RequestParamsValidation
  class GeneralError < StandardError
  end

  class RequestParamError < GeneralError
  end

  class DefinitionsError < GeneralError
  end
end

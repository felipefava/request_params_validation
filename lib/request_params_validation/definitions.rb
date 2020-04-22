require 'request_params_validation/definitions/resource'
require 'request_params_validation/exceptions/definitions_errors'

module RequestParamsValidation
  module Definitions
    @definitions = {}

    def self.load_all
      definitions_suffix = RequestParamsValidation.definitions_suffix
      Dir["#{definitions_path}/**/*#{definitions_suffix}.rb"].each { |file| require file }
    end

    def self.register_resource(&block)
      raise DefinitionArgumentError.new("Expecting block for resource definition") unless block_given?

      resource_name = resource_name_from_block(&block)
      resource = Resource.new(resource_name)

      block.call(resource)

      @definitions[resource_name] = resource
    end

    def self.get_request(resource, action)
      resource = @definitions[resource]

      return unless resource

      action = resource.actions[action]

      return unless action

      action.request
    end

    def self.definitions_path
      definitions_path = RequestParamsValidation.definitions_path.to_s

      definitions_path[0]  = '' if definitions_path.start_with?('/')
      definitions_path[-1] = '' if definitions_path.end_with?('/')

      "#{Rails.root}/#{definitions_path}"
    end
    private_class_method :definitions_path

    def self.resource_name_from_block(&block)
      definitions_suffix = RequestParamsValidation.definitions_suffix

      block_path = block.source_location.first

      block_path.sub("#{definitions_path}/", '')
                .sub("#{definitions_suffix}/", '')
                .sub('.rb', '')
    end
    private_class_method :resource_name_from_block
  end
end

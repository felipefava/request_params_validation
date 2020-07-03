require 'request_params_validation/params'

module RequestParamsValidation
  module Definitions
    class Param
      attr_reader :key, :required, :allow_blank, :type, :rename_as, :transform, :decimal_precision,
                  :inclusion, :length, :value, :format, :custom_validation, :if_given, :elements

      def initialize(options, &block)
        @key         = options[:key]
        @required    = options[:required]
        @allow_blank = options[:allow_blank]
        @type        = options[:type].try(:to_sym)
        @rename_as   = options[:as].try(:to_sym)
        @default     = options[:default]

        @transform          = options[:transform]
        @decimal_precision  = options[:precision]
        @element_of_array   = options[:element_of_array]

        @inclusion          = build_inclusion_option(options[:inclusion])
        @length             = build_length_option(options[:length])
        @value              = build_value_option(options[:value])
        @format             = build_format_option(options[:format])
        @custom_validation  = build_custom_validation_option(options[:validate])
        @if_given           = build_if_given_option(options[:if_given])

        @elements           = build_elements_option(options[:elements], &block)
        @sub_definition     = build_sub_definition(&block)
      end

      def has_default?
        !@default.nil? # default value could be `false`
      end

      def default
        @default.respond_to?(:call) ? @default.call : @default
      end

      def sub_definition
        @sub_definition || @elements.try(:sub_definition)
      end

      def element_of_array?
        !!@element_of_array
      end

      def validate_presence?
        !!@required
      end

      def validate_type?
        !!@type
      end

      def validate_inclusion?
        !!@inclusion
      end

      def validate_length?
        !!@length
      end

      def validate_value?
        !!@value
      end

      def validate_format?
        return false if [Params::DATE_TYPE, Params::DATETIME_TYPE].include?(@type)

        !!@format
      end

      def validate_custom_validation?
        !!@custom_validation
      end

      def rename?
        !!@rename_as
      end

      def transform?
        !!@transform
      end

      def skip?(request_params)
        return false unless @if_given

        if_given_param_value = request_params[@if_given.param]

        if @if_given.function
          !@if_given.function.call(if_given_param_value)
        else
          if_given_param_value.blank?
        end
      end

      private

      def build_inclusion_option(inclusion)
        case inclusion
        when Array
          include_in = inclusion
        when Hash
          include_in = inclusion[:in]
          message = inclusion[:message]
        end

        return unless include_in

        Struct.new(:in, :message).new(include_in, message)
      end

      def build_length_option(length)
        case length
        when Integer
          min = length
          max = length
        when Hash
          min = length[:min]
          max = length[:max]
          message = length[:message]
        end

        return unless min || max

        Struct.new(:min, :max, :message).new(min, max, message)
      end

      def build_value_option(value)
        case value
        when Hash
          min = value[:min]
          max = value[:max]
          message = value[:message]
        end

        return unless min || max

        Struct.new(:min, :max, :message).new(min, max, message)
      end

      def build_format_option(format)
        case format
        when Regexp
          regexp = format
        when String
          strptime = format
        when Hash
          strptime = format[:strptime]
          regexp   = format[:regexp]
          message  = format[:message]
        end

        return if regexp.nil? && !strptime

        Struct.new(:regexp, :strptime, :message).new(regexp, strptime, message)
      end

      def build_custom_validation_option(validation)
        case validation
        when Proc
          function = validation
        when Hash
          function = validation[:function]
          message = validation[:message]
        end

        return unless function

        Struct.new(:function, :message).new(function, message)
      end

      def build_if_given_option(if_given)
        case if_given
        when String, Symbol
          param = if_given.to_sym
        when Hash
          param = if_given.first.try(:first)
          function = if_given.first.try(:last)
        end

        return unless param

        Struct.new(:param, :function).new(param, function)
      end

      def build_elements_option(elements, &block)
        return unless @type == Params::ARRAY_TYPE

        elements_options = {
          key: @key,
          element_of_array: true
        }

        case elements
        when Hash
          elements_options.merge!(elements)
        when String, Symbol
          elements_options.merge!(type: elements)
        end

        self.class.new(elements_options, &block)
      end

      def build_sub_definition(&block)
        return unless @type == Params::HASH_TYPE

        request = Request.new

        block.call(request) if block_given?

        request.params
      end
    end
  end
end

# frozen_string_literal: true

module Unitsml
  module Conversion
    # Executes a UnitsML conversion definition (the Float64ConversionFrom
    # linear equation): forward y = d + ((b / c) (x + a)); inverse
    # x = (c / b) (y - d) - a. Exact arithmetic throughout: the lexical
    # decimal attributes parse to Rationals, and exact="true" definitions
    # produce exact values. SpecialConversionFrom and WSDLConversionFrom
    # are refused, never approximated.
    class Definition
      attr_reader :model

      # model: the Model::Units::Float64ConversionFrom. document_units:
      # an optional hash of document-local unit ids (without '#') to
      # anything the caller can resolve, used for '#frag' initialUnit
      # references before the register is consulted.
      def initialize(model, document_units: {})
        @model = model
        @document_units = document_units || {}
      end

      def self.from_model(model, document_units: {})
        case model
        when Model::Units::Float64ConversionFrom
          new(model, document_units: document_units)
        when Model::Units::SpecialConversionFrom
          raise Errors::ConversionError,
                "SpecialConversionFrom #{model.id.inspect} is not " \
                "executable: non-linear conversions have no linear " \
                "approximation"
        when Model::Units::WsdlConversionFrom
          raise Errors::ConversionError,
                "WSDLConversionFrom #{model.id.inspect} is not executable: " \
                "remote conversions are not evaluated"
        else
          raise Errors::ConversionError,
                "unknown conversion definition #{model.class}"
        end
      end

      def exact?
        model.exact == true
      end

      # Forward: this unit's definition converts the initial unit's value
      # into this unit: y = d + ((b / c) (x + a)).
      def forward(value)
        x = Rational(value)
        d + ((b / c) * (x + a))
      end

      # Inverse: from this unit back to the initial unit:
      # x = (c / b) (y - d) - a.
      def inverse(value)
        y = Rational(value)
        ((c / b) * (y - d)) - a
      end

      # The initial unit's identity: the '#fragment' stripped of its
      # leading '#', or the URI as given for register resolution.
      def initial_unit_id
        model.initial_unit.to_s.delete_prefix("#")
      end

      # Resolve the initialUnit against document-local units first, the
      # register second; unresolvable is a typed error naming the URI.
      def resolve_initial_unit
        uri = model.initial_unit.to_s
        if uri.start_with?("#")
          frag = initial_unit_id
          return @document_units[frag] if @document_units.key?(frag)

          raise Errors::ConversionError,
                "unresolvable initialUnit #{uri.inspect}: not defined in " \
                "the enclosing document"
        end

        record = Unitsml::Unitsdb.units.find_by_id(initial_unit_id)
        return record if record

        raise Errors::ConversionError,
              "unresolvable initialUnit #{uri.inspect}: not found " \
              "in the register"
      end

      private

      def a
        Rational(model.lexical_decimal(:initial_addend))
      end

      def b
        Rational(model.lexical_decimal(:multiplicand))
      end

      def c
        Rational(model.lexical_decimal(:divisor))
      end

      def d
        Rational(model.lexical_decimal(:final_addend))
      end
    end
  end
end

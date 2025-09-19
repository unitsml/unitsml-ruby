# frozen_string_literal: true

require "parslet"
require "unitsml/unitsdb"
require_relative "intermediate_exp_rules"
module Unitsml
  class Parse < Parslet::Parser
    include IntermediateExpRules

    rule(:sqrt)  { str("sqrt") }
    rule(:power) { str("^") >> slashed_number_int_exp.as(:power_numerator) }
    rule(:hyphen) { str("-") }
    rule(:number) { hyphen.maybe >> match(/[0-9]/).repeat(1) }
    rule(:spaces) { match(/\s/).repeat(1) }
    rule(:spaces?) { spaces.maybe }

    rule(:extender) { (forward_slashes | str("*")).as(:extender) }
    rule(:sequence) { single_letter_prefixes >> units | double_letter_prefixes >> units | units }

    rule(:opening_paren)   { str("(")}
    rule(:closing_paren)   { str(")")}
    rule(:unit_and_power)  { units >> power.maybe }
    rule(:slashed_number)  { (number >> (forward_slashes >> number).maybe).as(:integer) }
    rule(:forward_slashes) { str("//") | str("/") }
    rule(:dimension_rules) { (sqrt_dimensions | powered_dimensions) >> extended_dimension_rules.maybe }
    rule(:powered_dimensions) { dimensions >> power.maybe }

    rule(:units) do
      @@filtered_units ||= arr_to_expression(Unitsdb.units.filtered, "unit")
    end

    rule(:single_letter_prefixes) do
      @@prefixes1 ||= arr_to_expression(Unitsdb.prefixes_by_size(1), "prefix")
    end

    rule(:double_letter_prefixes) do
      @@prefixes2 ||= arr_to_expression(Unitsdb.prefixes_by_size(2), "prefix")
    end

    rule(:dimensions) do
      @@dimensions ||= arr_to_expression(Unitsdb.dimensions.parsables.keys, "dimension")
    end

    rule(:prefixes_units) do
      (sqrt_sequence >> extended_prefixed_units.maybe) |
        (str("1").as(:unit) >> extended_prefixed_units.maybe) |
        (unit_and_power >> extended_prefixed_units) |
        unit_and_power >> (any.absent? | (extender | opening_paren | closing_paren | spaces).present?) |
        (double_letter_prefixes >> unit_and_power >> extended_prefixed_units) |
        (double_letter_prefixes >> unit_and_power) |
        (single_letter_prefixes >> unit_and_power >> extended_prefixed_units) |
        (single_letter_prefixes >> unit_and_power)
    end

    rule(:expression) do
      prefixes_units_int_exp |
        dimension_rules_int_exp |
        single_letter_prefixes >> hyphen |
        double_letter_prefixes >> hyphen
    end

    root :expression

    def arr_to_expression(arr, file_name)
      array = arr&.flatten&.compact&.sort_by(&:length).reverse
      array&.reduce do |expression, expr_string|
        expression = str(expression).as(file_name.to_sym) if expression.is_a?(String)
        expression | str(expr_string).as(file_name.to_sym)
      end
    end
  end
end

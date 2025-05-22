# frozen_string_literal: true

require "parslet"
require "unitsml/unitsdb"
module Unitsml
  module IntermediateExpRules
    include Parslet

    # Rules for slashed number
    rule(:slashed_number_int_exp) { slashed_number | str("(") >> slashed_number_named_exp >> str(")") }
    rule(:slashed_number_named_exp) { slashed_number | str("(").as(:open_parenthesis) >> slashed_number_named_exp >> str(")").as(:close_parenthesis) }

    # Rules for prefixes_units
    rule(:prefixes_units_int_exp) { prefixes_units | str("(") >> prefixes_units_named_exp >> str(")") }
    rule(:prefixes_units_named_exp) { prefixes_units | str("(").as(:open_parenthesis) >> prefixes_units_named_exp >> str(")").as(:close_parenthesis) }

    # Rules for dimension_rules
    rule(:dimension_rules_int_exp) { dimension_rules | str("(") >> dimension_rules_named_exp >> str(")") }
    rule(:dimension_rules_named_exp) { dimension_rules | str("(").as(:open_parenthesis) >> dimension_rules_named_exp >> str(")").as(:close_parenthesis) }

    # Rules for dimensions
    rule(:powered_dimensions) { dimensions >> power.maybe }
    rule(:dimensions_int_exp) { powered_dimensions | str("(") >> dimensions_named_exp >> str(")") }
    rule(:dimensions_named_exp) { powered_dimensions | str("(").as(:open_parenthesis) >> dimensions_named_exp >> str(")").as(:close_parenthesis) }
  end

  class Parse < Parslet::Parser
    include IntermediateExpRules

    rule(:power)  { str("^") >> slashed_number_int_exp }
    rule(:hyphen) { str("-") }
    rule(:number) { hyphen.maybe >> match(/[0-9]/).repeat(1) }

    rule(:extender) { (forward_slashes | str("*")).as(:extender) }
    rule(:sequence) { single_letter_prefixes >> units | double_letter_prefixes >> units | units }

    rule(:unit_and_power)  { units >> power.maybe }
    rule(:slashed_number)  { (number >> (forward_slashes >> number).maybe).as(:integer) }
    rule(:forward_slashes) { str("//") | str("/") }

    rule(:units) do
      @@filtered_units ||= arr_to_expression(Unitsdb.units.filtered, "units")
    end

    rule(:single_letter_prefixes) do
      @@prefixes1 ||= arr_to_expression(Unitsdb.prefixes_by_size(1), "prefixes")
    end

    rule(:double_letter_prefixes) do
      @@prefixes2 ||= arr_to_expression(Unitsdb.prefixes_by_size(2), "prefixes")
    end

    rule(:dimensions) do
      @@dimensions ||= arr_to_expression(Unitsdb.dimensions.parsables.keys, "dimensions")
    end

    rule(:prefixes_units) do
      (sqrt(sequence) >> (extender >> prefixes_units_int_exp.as(:sequence)).as(:sequence)) |
        (str("1").as(:units) >> (extender >> prefixes_units_int_exp.as(:sequence)).as(:sequence)) |
        (unit_and_power >> extender >> prefixes_units_int_exp.as(:sequence)) |
        unit_and_power |
        (single_letter_prefixes >> unit_and_power >> extender >> prefixes_units_int_exp.as(:sequence)) |
        (single_letter_prefixes >> unit_and_power) |
        (double_letter_prefixes >> unit_and_power >> extender >> prefixes_units_int_exp.as(:sequence)) |
        (double_letter_prefixes >> unit_and_power)
    end

    rule(:dimension_rules) do
      (sqrt(dimensions_int_exp) >> (extender >> dimension_rules_int_exp.as(:sequence)).maybe) |
        (powered_dimensions >> (extender >> dimension_rules_int_exp.as(:sequence)).as(:sequence))
    end

    rule(:expression) do
      prefixes_units_named_exp |
        dimension_rules_named_exp |
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

    def sqrt(rule)
      str("sqrt(") >> rule.as(:sqrt) >> str(")")
    end
  end
end

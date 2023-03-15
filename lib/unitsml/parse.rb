# frozen_string_literal: true

require "parslet"
require_relative "unitsdb"
module Unitsml
  class Parse < Parslet::Parser
    include Unitsml::Unitsdb

    rule(:power)  { str("^") >> intermediate_exp(number) }
    rule(:units)  { @@units ||= arr_to_expression(Unitsdb.units.keys, "units") }
    rule(:number) { (str("-").maybe >> match(/[0-9]/).repeat(1)).as(:integer) }

    rule(:extender)   { (str("*") | str("/")).as(:extender) }
    rule(:prefixes)   { @@prefixes ||= arr_to_expression(Unitsdb.prefixes.keys, "prefixes") }
    rule(:dimensions) { @@dimensions ||= arr_to_expression(Unitsdb.dimensions.keys, "dimensions") }

    rule(:unit_and_power)      { units >> power.maybe }
    rule(:prefix_and_unit)     { prefixes >> unit_and_power }
    rule(:double_letter_units) { @@double_letters ||= arr_to_expression(Unitsdb.double_letter_units.keys, "units") }

    rule(:prefixes_units) do
      (sqrt(double_letter_units | prefix_and_unit | unit_and_power) >> extend_exp(prefixes_units)) |
        (double_letter_units >> extend_exp(prefixes_units)) |
        ((prefix_and_unit | unit_and_power) >> extend_exp(prefixes_units))
    end

    rule(:dimension_rules) do
      (sqrt(intermediate_exp(dimensions >> power.maybe)) >> extend_exp(dimension_rules)) |
        (dimensions >> power.maybe >> extend_exp(dimension_rules))
    end

    rule(:expression) do
      intermediate_exp(prefixes_units) |
        intermediate_exp(dimension_rules) |
        prefixes >> str("-")
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

    def extend_exp(rule)
      (extender >> intermediate_exp(rule).as(:sequence)).maybe
    end

    def intermediate_exp(rule)
      rule | (str("(") >> rule >> str(")"))
    end
  end
end

module Unitsml
  module IntermediateExpRules
    include Parslet

    # Rules for slashed number
    rule(:slashed_number_int_exp) { slashed_number | (str("(") >> slashed_number >> str(")")) }

    # Rules for prefixes_units
    rule(:prefixes_units_int_exp) { prefixes_units | (str("(") >> prefixes_units_named_exp.as(:intermediate_exp) >> str(")") >> extended_prefixed_units.maybe) }
    rule(:extended_prefixed_units) { extender >> prefixes_units_int_exp.as(:sequence) }
    rule(:prefixes_units_named_exp) do
      prefixes_units |
        ((str("(").as(:open_parenthesis) >> prefixes_units_int_exp.as(:int_exp) >> str(")").as(:close_parenthesis)).as(:intermediate_exp) >> extended_prefixed_units.maybe)
    end

    # Rules for dimension_rules
    rule(:dimension_rules_int_exp) { dimension_rules | (str("(") >> dimension_rules_named_exp.as(:intermediate_exp) >> str(")") >> extended_dimension_rules.maybe) }
    rule(:extended_dimension_rules) { extender >> dimension_rules_int_exp.as(:sequence) }
    rule(:dimension_rules_named_exp) do
      dimension_rules |
        ((str("(").as(:open_parenthesis) >> dimension_rules_int_exp.as(:int_exp) >> str(")").as(:close_parenthesis)).as(:intermediate_exp) >> extended_dimension_rules.maybe)
    end

    # Rules for dimensions
    rule(:sqrt_dimensions) { str("sqrt(") >> dimensions_int_exp.as(:sqrt) >> str(")") }
    rule(:powered_dimensions) { dimensions >> power.maybe }
    rule(:dimensions_int_exp) { powered_dimensions | (str("(") >> dimensions_named_exp.as(:intermediate_exp) >> str(")")) }
    rule(:dimensions_named_exp) { powered_dimensions | (str("(").as(:open_parenthesis) >> dimensions_int_exp.as(:int_exp) >> str(")").as(:close_parenthesis)) }

    # Rules for sequence
    rule(:sqrt_sequence) { str("sqrt(") >> sequence_int_exp.as(:sqrt) >> str(")") }
    rule(:sequence_int_exp) { sequence | (str("(") >> sequence_named_exp.as(:intermediate_exp)>> str(")")) }
    rule(:sequence_named_exp) { sequence | (str("(").as(:open_parenthesis) >> sequence_int_exp.as(:int_exp) >> str(")").as(:close_parenthesis)) }
  end
end

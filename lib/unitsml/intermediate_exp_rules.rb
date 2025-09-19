module Unitsml
  module IntermediateExpRules
    include Parslet

    # Rules for slashed number
    rule(:slashed_number_int_exp) { slashed_number | (opening_paren >> slashed_number_named_int_exp.as(:int_exp) >> closing_paren) }
    rule(:slashed_number_named_int_exp) do
      (opening_paren.as(:open_paren) >> slashed_number_int_exp >> closing_paren.as(:close_paren)) |
        slashed_number_int_exp
    end

    # Rules for prefixes_units
    rule(:wrapper_prefixes_units_value) { int_exp_prefixes_units | prefixes_units_int_exp }

    rule(:extended_prefixed_units) { extender >> spaces? >> prefixes_units_int_exp.as(:sequence) }

    rule(:int_exp_prefixes_units) { opening_paren >> spaces? >> named_int_exp_prefixes_units.as(:int_exp) >> spaces? >> closing_paren }

    rule(:implicit_extended) do
      prefixes_units.as(:first_set) >> spaces.as(:extender) >> prefixes_units.as(:second_set) |
        int_exp_prefixes_units.as(:first_int_exp_set) >> spaces? >> int_exp_prefixes_units.as(:second_int_exp_set) |
        prefixes_units.as(:first_set) >> spaces? >> int_exp_prefixes_units.as(:second_int_exp_set) |
        int_exp_prefixes_units.as(:first_int_exp_set) >> spaces? >> prefixes_units.as(:second_set)
    end

    rule(:prefixes_units_int_exp) do
      implicit_extended.as(:implicit_extended) >> spaces? >> prefixes_units_int_exp.as(:sequence).maybe |
        implicit_extended.as(:implicit_extended) >> spaces? >> extender >> spaces? >> prefixes_units_int_exp.as(:sequence).maybe |
        int_exp_prefixes_units >> spaces? >> extender >> spaces? >> prefixes_units_int_exp.as(:sequence).maybe |
        prefixes_units >> spaces? >> extender >> spaces? >> prefixes_units_int_exp.as(:sequence).maybe |
        int_exp_prefixes_units >> prefixes_units_int_exp.as(:sequence).maybe |
        prefixes_units >> prefixes_units_int_exp.as(:sequence).maybe
    end

    rule(:prefixes_units_named_int_exp) do
      opening_paren.as(:open_paren) >> spaces? >> wrapper_prefixes_units_value.as(:int_exp) >> spaces? >> closing_paren.as(:close_paren)
    end

    rule(:named_int_exp_prefixes_units) do
      prefixes_units_named_int_exp.as(:int_exp) >> (prefixes_units_int_exp | extended_prefixed_units).maybe |
        prefixes_units_int_exp
    end

    # Rules for dimension_rules
    rule(:dimension_rules_int_exp) do
      dimension_rules.as(:first_set) >> spaces.as(:extender) >> dimension_rules.as(:second_set) >> dimension_rules_int_exp.maybe |
        dimension_rules.as(:first_set) >> spaces? >> int_exp_dimension_rules.as(:second_int_exp_set) >> dimension_rules_int_exp.maybe |
        int_exp_dimension_rules.as(:first_int_exp_set) >> spaces? >> dimension_rules.as(:second_set) >> dimension_rules_int_exp.maybe |
        int_exp_dimension_rules.as(:first_int_exp_set) >> spaces? >> int_exp_dimension_rules.as(:second_int_exp_set) >> dimension_rules_int_exp.maybe |
        int_exp_dimension_rules |
        dimension_rules
    end

    rule(:int_exp_dimension_rules) { opening_paren >> dimension_rules_named_exp.as(:int_exp) >> closing_paren >> extended_dimension_rules.maybe }

    rule(:extended_dimension_rules) { spaces? >> extender >> spaces? >> dimension_rules_int_exp.as(:sequence) }
    rule(:dimension_rules_named_exp) do
      ((opening_paren.as(:open_paren) >> dimension_rules_int_exp.as(:int_exp) >> closing_paren.as(:close_paren)).as(:int_exp) >> spaces? >> (dimension_rules_int_exp | extended_dimension_rules).as(:sequence).maybe) |
        dimension_rules_int_exp
    end

    # Rules for dimensions
    rule(:sqrt_dimensions) { sqrt >> opening_paren >> dimension_rules_int_exp.as(:sqrt) >> closing_paren }

    # Rules for sequence
    rule(:sqrt_sequence) { sqrt >> opening_paren >> prefixes_units_int_exp.as(:sqrt) >> closing_paren }
  end
end

# frozen_string_literal: true

require "parslet"
module Unitsml
  class Transform < Parslet::Transform
    rule(sqrt: simple(:sqrt)) { Sqrt.new(sqrt) }
    rule(unit: simple(:unit)) { Unit.new(unit.to_s) }
    rule(dimension: simple(:dimension)) { Dimension.new(dimension.to_s) }
    rule(prefix: simple(:prefix)) { Prefix.new(prefix.to_s) }
    rule(int_exp: simple(:int_exp)) { int_exp }
    rule(implicit_extended: simple(:implicit_extended)) { implicit_extended }

    rule(int_exp: simple(:int_exp),
         sequence: simple(:sequence)) do
      Formula.new([int_exp, sequence])
    end

    rule(first_int_exp_set: simple(:first_set),
         second_set: simple(:second_set)) do
      Formula.new([Utility.set_to_fence(first_set), second_set])
    end

    rule(first_int_exp_set: simple(:first_set),
         second_int_exp_set: simple(:second_set)) do
      Formula.new(
        [Utility.set_to_fence(first_set), Utility.set_to_fence(second_set),
        ]
      )
    end

    rule(first_set: simple(:first_set),
         second_set: simple(:second_set)) do
      Formula.new(
        [
          first_set,
          second_set,
        ]
      )
    end

    rule(first_set: simple(:first_set),
         second_int_exp_set: simple(:second_set)) do
      Formula.new(
        [
          first_set,
          Utility.set_to_fence(second_set),
        ]
      )
    end

    rule(prefix: simple(:prefix),
         unit: simple(:unit)) do
      Unit.new(unit.to_s, prefix: Prefix.new(prefix.to_s))
    end

    rule(unit: simple(:unit),
         integer: simple(:integer)) do
      Unit.new(unit.to_s, integer)
    end

    rule(dimension: simple(:dimension),
         integer: simple(:integer)) do
      Dimension.new(dimension.to_s, integer)
    end

    rule(prefix: simple(:prefix),
         unit: simple(:unit),
         integer: simple(:integer)) do
      Unit.new(unit.to_s, integer.to_s, prefix: Prefix.new(prefix.to_s))
    end

    rule(first_set: simple(:first_set),
         extender: simple(:extender),
         second_set: simple(:second_set)) do
      Formula.new(
        [
          first_set,
          Extender.new(extender.to_s),
          second_set,
        ]
      )
    end

    rule(implicit_extended: simple(:implicit_extended),
         extender: simple(:extender),
         sequence: simple(:sequence)) do
      Formula.new(
        [
          implicit_extended,
          Extender.new(extender.to_s),
          sequence,
        ]
      )
    end

    rule(int_exp: simple(:int_exp),
         extender: simple(:extender),
         sequence: simple(:sequence)) do
      Formula.new(
        [
          int_exp,
          Extender.new(extender.to_s),
          sequence,
        ]
      )
    end

    rule(unit: simple(:unit),
         extender: simple(:extender),
         sequence: simple(:sequence)) do
      Formula.new(
        [
          Unit.new(unit.to_s),
          Extender.new(extender.to_s),
          sequence,
        ]
      )
    end

    rule(dimension: simple(:dimension),
         extender: simple(:extender),
         sequence: simple(:sequence)) do
      Formula.new(
        [
          Dimension.new(dimension.to_s),
          Extender.new(extender.to_s),
          sequence,
        ]
      )
    end

    rule(open_paren: simple(:open_paren),
         int_exp: simple(:int_exp),
         close_paren: simple(:close_paren)) do
      Fenced.new(
        open_paren.to_s,
        int_exp,
        close_paren.to_s,
      )
    end

    rule(unit: simple(:unit),
         integer: simple(:int),
         extender: simple(:ext),
         sequence: simple(:sequence)) do
      Formula.new(
        [
          Unit.new(unit.to_s, int.to_s),
          Extender.new(ext.to_s),
          sequence,
        ],
      )
    end

    rule(dimension: simple(:dimension),
         integer: simple(:int),
         extender: simple(:ext),
         sequence: simple(:sequence)) do
      Formula.new(
        [
          Dimension.new(dimension.to_s, int.to_s),
          Extender.new(ext.to_s),
          sequence,
        ],
      )
    end

    rule(prefix: simple(:prefix),
         unit: simple(:unit),
         extender: simple(:ext),
         sequence: simple(:sequence)) do
      Formula.new(
        [
          Unit.new(unit.to_s, prefix: Prefix.new(prefix.to_s)),
          Extender.new(ext.to_s),
          sequence,
        ],
      )
    end

    rule(prefix: simple(:prefix),
         unit: simple(:unit),
         integer: simple(:integer),
         extender: simple(:ext),
         sequence: simple(:sequence)) do
      Formula.new(
        [
          Unit.new(unit.to_s, integer.to_s, prefix: Prefix.new(prefix.to_s)),
          Extender.new(ext.to_s),
          sequence,
        ],
      )
    end
  end
end

module Asciimath2UnitsML
  class Conv
    def units_only(units)
      units.reject { |u| u[:multiplier] }
    end

    def unit_id(text)
      text = text.gsub(/[()]/, "")
      "U_" +
        (@units[text] ? @units[text].id : text.gsub(/\*/, ".").gsub(/\^/, ""))
    end

    def unit(units, origtext, normtext, dims, name)
      dimid = dim_id(dims)
      norm_units = normalise_units(units)
      <<~END
      <Unit xmlns='#{UNITSML_NS}' xml:id='#{unit_id(normtext)}'#{dimid ? " dimensionURL='##{dimid}'" : ""}>
      #{unitsystem(units)}
      #{unitname(norm_units, normtext, name)}
      #{unitsymbol(norm_units)}
      #{rootunits(units)}
      </Unit>
      END
    end

    def normalise_units(units)
      units.map do |u|
        u1 = u.dup
        u1[:multiplier] and u1[:multiplier] = "*"
        u1[:exponent] and u1[:display_exponent] = u1[:exponent]
        u1
      end
    end

    # kg exception
    def unitsystem(units)
      ret = []
      units = units_only(units)
      units.any? { |x| @units[x[:unit]].system_name != "SI" } and
        ret << "<UnitSystem name='not_SI' type='not_SI' xml:lang='en-US'/>"
      if units.any? { |x| @units[x[:unit]].system_name == "SI" }
        base = units.size == 1 && @units[units[0][:unit]].system_type == "SI-base"
        base = true if units.size == 1 && units[0][:unit] == "g" && units[0][:prefix] == "k"
        ret << "<UnitSystem name='SI' type='#{base ? "SI_base" : "SI_derived"}' xml:lang='en-US'/>"
      end
      ret.join("\n")
    end

    def unitname(units, text, name)
      name ||= @units[text] ? @units[text].name : compose_name(units, text)
      "<UnitName xml:lang='en'>#{name}</UnitName>"
    end

    # TODO: compose name from the component units
    def compose_name(units, text)
      text
    end

    def unitsymbol(units)
      <<~END
      <UnitSymbol type="HTML">#{htmlsymbol(units, true)}</UnitSymbol>
      <UnitSymbol type="MathML">#{mathmlsymbolwrap(units, true)}</UnitSymbol>
      END
    end

    def rootunits(units)
      return if units.size == 1 && !units[0][:prefix]
      exp = units_only(units).map do |u|
        prefix = " prefix='#{u[:prefix]}'" if u[:prefix]
        exponent = " powerNumerator='#{u[:exponent]}'" if u[:exponent] && u[:exponent] != "1"
        "<EnumeratedRootUnit unit='#{@units[u[:unit]].name}'#{prefix}#{exponent}/>"
      end.join("\n")
      <<~END
      <RootUnits>#{exp}</RootUnits>
      END
    end
  end
end
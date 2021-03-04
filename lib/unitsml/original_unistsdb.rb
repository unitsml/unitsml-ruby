module UnitsDB
  class Dimension
    attr_reader :id, :length, :mass, :time, :electric_current, :thermodynamic_temperature,
      :amount_of_substance, :luminous_intensity, :plane_angle, :dimensionless

    def initialize(id, hash)
      begin
        @id = id
        @dimensionless = hash[:dimensionless]
        hash[:length] and @length = hash[:length][:powerNumerator].to_i
        hash[:mass] and @mass = hash[:mass][:powerNumerator].to_i
        hash[:time] and @time = hash[:time][:powerNumerator].to_i
        hash[:electric_current] and @electric_current = hash[:electric_current][:powerNumerator].to_i
        hash[:thermodynamic_temperature] and
          @thermodynamic_temperature = hash[:thermodynamic_temperature][:powerNumerator].to_i
        hash[:amount_of_substance] and @amount_of_substance = hash[:amount_of_substance][:powerNumerator].to_i
        hash[:luminous_intensity] and @luminous_intensity = hash[:luminous_intensity][:powerNumerator].to_i
        hash[:plane_angle] and @plane_angle = hash[:plane_angle][:powerNumerator].to_i
      rescue
        raise StandardError.new "Parse fail on Dimension #{id}: #{hash}"
      end
    end

    def keys
      ret = []
      @length and ret << "Length"
      @mass and ret << "Mass"
      @time and ret << "Time"
      @electric_current and ret << "ElectricCurrent"
      @thermodynamic_temperature and ret << "ThermodynamicTemperature"
      @amount_of_substance and ret << "AmountOfSubstance"
      @luminous_intensity and ret << "LuminousIntensity"
      @plane_angle and ret << "PlaneAngle"
      ret
    end

    def exponent(key)
      case key
      when "Length" then @length
      when "Mass" then @mass
      when "Time" then @time
      when "ElectricCurrent" then @electric_current
      when "ThermodynamicTemperature" then @thermodynamic_temperature
      when "AmountOfSubstance" then @amount_of_substance
      when "LuminousIntensity" then @luminous_intensity
      when "PlaneAngle" then @plane_angle
      end
    end

    def vector
      "#{@length}:#{@mass}:#{@time}:#{@electric_current}:#{@thermodynamic_temperature}:#{@amount_of_substance}:"\
        "#{@luminous_intensity}:#{@plane_angle}"
    end
  end

  class Prefix
    attr_reader :id, :name, :base, :power, :symbol

    def initialize(id, hash)
      begin
        @id = id
        @name = hash[:name]
        @base = hash[:base]
        @power = hash[:power]
        @symbol = hash[:symbol] # always is a hash
      rescue
        raise StandardError.new "Parse fail on Prefix #{id}: #{hash}"
      end
    end

    def ascii
      @symbol[:ascii]
    end

    def symbolid
      @symbol[:ascii]
    end

    def html
      @symbol[:html]
    end

    def mathml
      @symbol[:html]
    end

    def latex
      @symbol[:latex]
    end

    def unicode
      @symbol[:unicode]
    end
  end

  class Quantity
    attr_reader :id, :dimension, :type, :names, :units

    def initialize(id, hash)
      begin
        @id = id
        @dimension = hash[:dimension_url].sub(/^#/, "")
        @type = hash[:quantity_type]
        hash[:quantity_name] and @names = hash[:quantity_name]
        hash[:unit_reference] and @units = hash[:unit_reference].map { |x| x[:url].sub(/^#/, "") }
      rescue
        raise StandardError.new "Parse fail on Quantity #{id}: #{hash}"
      end
    end

    def name
      @names&.first
    end

    def unit
      @units&.first
    end
  end

  class Unit
    attr_reader :id, :dimension, :short, :root, :unit_system, :names, :symbols, :symbols_hash, :root_units, :quantities,
      :si_derived_bases, :prefixed

    def initialize(id, hash)
      begin
        @id = id
        @short = short
        @dimension = hash[:dimension_url].sub(/^#/, "")
        hash[:short] && !hash[:short].empty? and @short = hash[:short]
        @unit_system = hash[:unit_system]
        @names = hash[:unit_name]
        @symbols_hash = hash[:unit_symbols]&.each_with_object({}) { |h, m| m[h[:id]] = h } || {}
        @symbols = hash[:unit_symbols]
        hash[:root_units] and hash[:root_units][:enumerated_root_units] and
          @root = hash[:root_units][:enumerated_root_units]
        hash[:quantity_reference] and @quantities = hash[:quantity_reference].map { |x| x[:url].sub(/^#/, "") }
        hash[:si_derived_bases] and @si_derived_bases = hash[:si_derived_bases]
      rescue
        raise StandardError.new "Parse fail on Unit #{id}: #{hash}"
      end
    end

    def system_name
      @unit_system[:name]
    end

    def system_type
      @unit_system[:type]
    end

    def name
      @names.first
    end

    def symbolid
      @symbols ? @symbols.first[:id] : @short
    end

    def symbolids
      @symbols ? @symbols.map { |s| s[:id] } : [ @short ]
    end
  end
end
module Unitsml
  class Dimension
    UNITS_DB_DIMENSIONS_PATH = File
                      .expand_path("../../vendor/unitsdb/dimensions.yaml",
                        File.dirname(__FILE__))
                      .freeze

    attr_reader :id,
      :length,
      :mass,
      :time,
      :electric_current,
      :thermodynamic_temperature,
      :amount_of_substance,
      :luminous_intensity,
      :plane_angle,
      :dimensionless

    class << self
      def find_dimension(ascii:)
        symbols.find { |unit| unit.id == ascii.to_s }
      end

      def symbols
        @symbols ||= YAML
                      .load(File.read(UNITS_DB_DIMENSIONS_PATH))
                      .map { |(id, attrs)| Unitsml::Dimension.new(id, attrs) }
      end

      def from_yaml(yaml_path)
        @symbols = YAML
                    .load(File.read(yaml_path))
                    .map { |(id, attrs)| Unitsml::Dimension.new(id, attrs) }
      end
    end

    def initialize(id, hash)
      begin
        @id = id
        @dimensionless = hash["dimensionless"]
        hash["length"] and @length = hash["length"]["powerNumerator"].to_i
        hash["mass"] and @mass = hash["mass"]["powerNumerator"].to_i
        hash["time"] and @time = hash["time"]["powerNumerator"].to_i
        hash["electric_current"] and @electric_current = hash["electric_current"]["powerNumerator"].to_i
        hash["thermodynamic_temperature"] and
          @thermodynamic_temperature = hash["thermodynamic_temperature"]["powerNumerator"].to_i
        hash["amount_of_substance"] and @amount_of_substance = hash["amount_of_substance"]["powerNumerator"].to_i
        hash["luminous_intensity"] and @luminous_intensity = hash["luminous_intensity"]["powerNumerator"].to_i
        hash["plane_angle"] and @plane_angle = hash["plane_angle"]["powerNumerator"].to_i
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
end

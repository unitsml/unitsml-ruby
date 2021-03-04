require "yaml"

module Unitsml
  class UnitSymbol
    attr_reader :id,
      :ascii,
      :html,
      :mathml,
      :latex,
      :unicode

    def initialize(id, hash)
      @id = hash['id']
      @ascii = hash['ascii']
      @html = hash['html']
      @mathml = hash['mathml']
      @latex = hash['latex']
      @unicode = hash['unicode']
    end
  end
end

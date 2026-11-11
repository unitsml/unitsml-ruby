# frozen_string_literal: true

module Unitsml
  # A data-declared quantity kind: one UnitsDB quantity record.
  #
  # Kind compatibility comes from the register, never from code: the
  # quantities schema's equivalence_class is "L1 equivalence class:
  # quantities in the same class are interchangeable for
  # addition/subtraction arithmetic (work, energy and heat share the energy
  # class). Absent means identity-only gating." (unitsdb
  # schemas/quantities-schema.yaml:47-49). So work + heat is legal (both
  # in the energy class) while torque + energy is refused although both
  # have dimension L2MT-2.
  class QuantityKind
    attr_reader :record

    # kind: a QuantityKind, a UnitsDB quantity record, or a String quantity
    # identifier or name ("NISTq18", "work").
    def self.resolve(kind)
      case kind
      when QuantityKind then kind
      when ::Unitsdb::Quantity then new(kind)
      when String
        record = Utility.quantity_instance(kind)
        unless record
          raise Errors::UnknownQuantityKindError,
                "unknown quantity kind #{kind.inspect}"
        end

        new(record)
      else
        raise Errors::UnknownQuantityKindError,
              "a quantity kind is a String identifier or name, " \
              "got #{kind.class}"
      end
    end

    # The primary quantity of a UnitsDB unit record. The units schema
    # marks it explicitly: "True for the primary quantity of this unit ...
    # Consumers select this reference instead of positional order."
    # (unitsdb schemas/units-schema.yaml:147-149). Selection reads the flag
    # only, so the result does not depend on the order of
    # quantity_references in the data.
    #
    # A sole reference with the flag ABSENT is the unit's quantity: the
    # schema leaves the field optional, and the release that introduced it
    # flags only multi-reference units ("96 multi-reference units flagged,
    # exactly one primary each", unitsdb 6f3d156, schema 2.2.0). That
    # inference is not stated in the schema text itself. A reference marked
    # primary: false is never promoted, even when it is the only one.
    # Several references with no true flag, or more than one, is a register
    # defect and fails explicitly.
    def self.primary_for(unit_record) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      refs = unit_record&.quantity_references.to_a
      return nil if refs.empty?

      flagged = refs.select { |ref| ref.primary == true }
      chosen = case flagged.size
               when 1 then flagged.first
               when 0 then sole_unflagged(unit_record, refs)
               else
                 raise Errors::PrimaryQuantityError,
                       "unit #{unit_label(unit_record)} marks " \
                       "#{flagged.size} quantity references primary"
               end
      resolve(chosen.id)
    end

    def self.sole_unflagged(unit_record, refs)
      if refs.size > 1
        raise Errors::PrimaryQuantityError,
              "unit #{unit_label(unit_record)} has #{refs.size} " \
              "quantity references and none is marked primary"
      end
      return refs.first if refs.first.primary.nil?

      raise Errors::PrimaryQuantityError,
            "unit #{unit_label(unit_record)} marks its only quantity " \
            "reference primary: false"
    end
    private_class_method :sole_unflagged

    def self.unit_label(record)
      record.identifiers.to_a.map(&:id).first.inspect
    end
    private_class_method :unit_label

    def initialize(record)
      @record = record
    end

    def id
      @id ||= record.identifiers.to_a.find { |i| i.type == "nist" }&.id ||
        record.identifiers.to_a.first&.id
    end

    def name
      record.names.to_a.find { |n| n.lang == "en" }&.value ||
        record.names.to_a.first&.value
    end

    def equivalence_class
      record.equivalence_class
    end

    def dimension_id
      record.dimension_reference&.id&.to_s
    end

    # Same quantity, or both in the same declared equivalence class. An
    # absent class means identity-only gating.
    def compatible?(other)
      return true if id == other.id

      !equivalence_class.nil? && equivalence_class == other.equivalence_class
    end

    def ==(other)
      other.is_a?(QuantityKind) && id == other.id
    end
    alias eql? ==

    def hash
      id.hash
    end

    def to_s
      id.to_s
    end

    def inspect
      "#<Unitsml::QuantityKind #{id} #{name.inspect}>"
    end
  end
end

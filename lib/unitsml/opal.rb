# frozen_string_literal: true

# Opal entry point for unitsml.
#
# Under MRI, lib/unitsml.rb uses autoload for lazy loading. Under Opal,
# autoload does not lazy-execute, so this boot file eager-requires every
# entry point. Consumers (e.g. plurimath-js) add `-r unitsml/opal` to
# their Opal compile command.
#
# Load order rationale:
#   1. Upstream boot files first — unitsml depends on lutaml-model,
#      unitsdb, mml (and transitively omml via plurimath-js consumers).
#   2. unitsml.rb next — sets up top-level autoloads and Configuration.
#   3. Errors before everything else (low-level, no deps).
#   4. The Opal payload — defines Unitsml::Unitsdb::Database::DATABASE
#      so Unitsml::Unitsdb::Database.from_db can satisfy without a
#      filesystem under Opal.
#   5. Unitsdb sub-files — define classes that subclass ::Unitsdb::*
#      and call Configuration.register_model side-effects.
#   6. Model tree — declares the Unitsml XML model classes. Each parent
#      module (Prefixes, Quantities, DimensionQuantities, Units) is
#      required first to set up its own autoloads, then its leaves.
#   7. Parser/Transform/Prefix/Unit/Dimension etc. — top-level domain
#      classes that reference Model and Unitsdb.

require "lutaml/model"
require "unitsdb/opal"
require "mml/opal"
require "omml/opal"

require "unitsml"

require "unitsml/version"
require "unitsml/errors"
require "unitsml/errors/base_error"
require "unitsml/errors/empty_composition_error"
require "unitsml/errors/invalid_model_error"
require "unitsml/errors/invalid_power_error"
require "unitsml/errors/invalid_unit_entry_error"
require "unitsml/errors/mixed_terms_error"
require "unitsml/errors/opal_payload_not_bundled_error"
require "unitsml/errors/plurimath_load_error"
require "unitsml/errors/unknown_dimension_error"
require "unitsml/errors/unknown_prefix_error"
require "unitsml/errors/unknown_unit_error"
require "unitsml/errors/unsupported_payload_type_error"

require "unitsml/opal/database_payload"

require "unitsml/configuration"
require "unitsml/namespace"

require "unitsml/unitsdb"
require "unitsml/unitsdb/database"
require "unitsml/unitsdb/dimension_details"
require "unitsml/unitsdb/finders"
require "unitsml/unitsdb/prefix_reference"
require "unitsml/unitsdb/dimension"
require "unitsml/unitsdb/dimensions"
require "unitsml/unitsdb/unit"
require "unitsml/unitsdb/units"
require "unitsml/unitsdb/prefixes"
require "unitsml/unitsdb/quantities"

require "unitsml/model"
require "unitsml/model/dimension"
require "unitsml/model/dimension_quantities"
require "unitsml/model/dimension_quantities/amount_of_substance"
require "unitsml/model/dimension_quantities/electric_current"
require "unitsml/model/dimension_quantities/length"
require "unitsml/model/dimension_quantities/luminous_intensity"
require "unitsml/model/dimension_quantities/mass"
require "unitsml/model/dimension_quantities/plane_angle"
require "unitsml/model/dimension_quantities/quantity"
require "unitsml/model/dimension_quantities/thermodynamic_temperature"
require "unitsml/model/dimension_quantities/time"
require "unitsml/model/prefix"
require "unitsml/model/prefixes"
require "unitsml/model/prefixes/name"
require "unitsml/model/prefixes/symbol"
require "unitsml/model/quantities"
require "unitsml/model/quantities/name"
require "unitsml/model/quantity"
require "unitsml/model/unit"
require "unitsml/model/units"
require "unitsml/model/units/enumerated_root_unit"
require "unitsml/model/units/name"
require "unitsml/model/units/root_units"
require "unitsml/model/units/symbol"
require "unitsml/model/units/system"

require "unitsml/compose"
require "unitsml/compose/term_tree"
require "unitsml/compose/builder"
require "unitsml/compose/composable"
require "unitsml/compose/composite"
require "unitsml/dimension"
require "unitsml/extender"
require "unitsml/fenced"
require "unitsml/fenced_numeric"
require "unitsml/formula"
require "unitsml/intermediate_exp_rules"
require "unitsml/mathml_helper"
require "unitsml/number"
require "unitsml/parse"
require "unitsml/parser"
require "unitsml/prefix"
require "unitsml/prefix_adapter"
require "unitsml/sqrt"
require "unitsml/transform"
require "unitsml/unit"
require "unitsml/utility"
require "unitsml/xml"
require "unitsml/xml/formatter"

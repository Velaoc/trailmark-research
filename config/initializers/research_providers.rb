# frozen_string_literal: true

# The registry and adapter modules live under app/services and are not
# autoloaded yet when this initializer runs, so require them explicitly
# before registering.
require_dependency "research_providers"
require_dependency "research_providers/demo"
require_dependency "research_providers/http"

# Registry for research provider adapters. RESEARCH_PROVIDER_NAME selects the
# active one; it defaults to the demo adapter in previews so the app is fully
# usable offline. A production deployment sets RESEARCH_PROVIDER_NAME=http and
# the RESEARCH_PROVIDER_* variables on the host — values live in the operator's
# secret store, never in the repository.
ResearchProviders.register(
  "demo" => ResearchProviders::Demo,
  "http" => ResearchProviders::Http
)
ResearchProviders.default_provider_name = ENV.fetch("RESEARCH_PROVIDER_NAME", "demo")

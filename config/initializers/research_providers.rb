# frozen_string_literal: true

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

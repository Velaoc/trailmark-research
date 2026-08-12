# frozen_string_literal: true

# Registry of research provider adapters. The agent loop resolves a provider
# by name through here; adapters live under ResearchProviders:: and are
# registered in config/initializers/research_providers.rb.
module ResearchProviders
  @registry = {}
  @default_provider_name = "demo"

  class << self
    def register(map)
      @registry.merge!(map.transform_keys(&:to_s))
    end

    def default_provider_name=(name)
      @default_provider_name = name.to_s
    end

    def default_provider_name
      @default_provider_name
    end

    def provider_for(name = nil)
      key = (name.presence || @default_provider_name).to_s
      klass = @registry[key]
      raise ArgumentError, "unknown research provider: #{key}" unless klass

      klass
    end

    def names
      @registry.keys
    end

    # name => { env_var => description }; used by the status/docs surface.
    # Values themselves are never exposed.
    def config_surface
      @registry.transform_values(&:config_surface)
    end
  end
end

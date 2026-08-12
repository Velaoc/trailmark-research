# frozen_string_literal: true

# Provider adapters turn a research step's plan and context into a prompt,
# call an LLM, and return the text result. A real deployment swaps the demo
# adapter for an HTTP-backed one without touching the agent loop.
#
# Configuration is read from ENV (never committed). The same keys are used by
# any HTTP-backed adapter, so a self-hoster only sets variables, never code.
module ResearchProviders
  class Base
    # The provider label stored on ResearchRun, e.g. "demo" or "openai".
    def self.name_key
      raise NotImplementedError
    end

    # True when this adapter is safe to use in a preview/offline environment.
    def self.demo?
      false
    end

    # Returns the provider's configuration surface for docs and status pages:
    # env var name => short description. Values themselves never appear.
    def self.config_surface
      {}
    end

    # Executes a step against the provider and returns the text result.
    # step: the ResearchStep being executed (title, input, position)
    # context: hash of prior step outputs keyed by position (1-based)
    def execute(step, context)
      raise NotImplementedError
    end
  end
end

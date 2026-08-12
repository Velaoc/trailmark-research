# frozen_string_literal: true

# Demo adapter: produces a plausible, deterministic result for every step with
# no network, no credentials, and no cost. It is the default in previews; the
# HTTP adapter is the real provider. Both share the same ResearchProviders::Base
# contract, so the agent loop never knows which one ran.
module ResearchProviders
  class Demo < Base
    def self.name_key
      "demo"
    end

    def self.demo?
      true
    end

    def execute(step, context)
      question = context[:question] || step.research_run&.question || ""
      [ "On #{Date.current.iso8601}, the trail reads as follows.",
        "Assignment for step #{step.position}: #{step.title}.",
        "Note: this is a deterministic demo result — configure RESEARCH_PROVIDER_URL/API_KEY/MODEL to run against a real model." ].join("\n\n")
    end
  end
end

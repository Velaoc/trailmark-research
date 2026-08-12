# frozen_string_literal: true

# Turns a research question into an ordered list of steps. The demo planner is
# deterministic: it always produces the same four-step decomposition so runs
# are reproducible without a model. A real deployment can swap in a planner
# that asks the provider to decompose first; the agent loop only needs
# step titles and inputs.
class ResearchPlanner
  DEMO_STEPS = [
    { title: "Clarify the question", input: "Restate the question precisely and list the assumptions it depends on." },
    { title: "Survey the landscape", input: "Identify the key actors, technologies, and prior work relevant to the question." },
    { title: "Dig into evidence", input: "Gather concrete facts, figures, and sources that bear on the question." },
    { title: "Synthesize the answer", input: "Weigh the evidence and write a clear, hedged conclusion." }
  ].freeze

  def self.plan(question)
    DEMO_STEPS.each_with_index.map do |step, index|
      { position: index + 1, title: step[:title], input: "#{step[:input]}\nQuestion: #{question}" }
    end
  end
end

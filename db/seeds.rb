# frozen_string_literal: true

# Seeds a single completed demo run so the timeline renders fully without any
# provider call. The demo provider is the default in previews; a real
# deployment just starts new runs with RESEARCH_PROVIDER_NAME=http.
if ResearchRun.count.zero?
  run = ResearchRun.create!(
    question: "How does the Vela pulsar's spin-down rate constrain its age?",
    status: "completed",
    provider_name: "demo",
    started_at: 2.minutes.ago,
    completed_at: 90.seconds.ago,
    step_count: 4
  )

  steps = [
    {
      title: "Clarify the question",
      status: "completed",
      started_at: 2.minutes.ago,
      completed_at: 110.seconds.ago,
      duration_ms: 1200,
      input: "Restate the question precisely and list the assumptions it depends on.\nQuestion: How does the Vela pulsar's spin-down rate constrain its age?"
    },
    {
      title: "Survey the landscape",
      status: "completed",
      started_at: 110.seconds.ago,
      completed_at: 105.seconds.ago,
      duration_ms: 4100,
      input: "Identify the key actors, technologies, and prior work relevant to the question.\nQuestion: How does the Vela pulsar's spin-down rate constrain its age?"
    },
    {
      title: "Dig into evidence",
      status: "completed",
      started_at: 105.seconds.ago,
      completed_at: 95.seconds.ago,
      duration_ms: 9600,
      input: "Gather concrete facts, figures, and sources that bear on the question.\nQuestion: How does the Vela pulsar's spin-down rate constrain its age?"
    },
    {
      title: "Synthesize the answer",
      status: "completed",
      started_at: 95.seconds.ago,
      completed_at: 90.seconds.ago,
      duration_ms: 5100,
      input: "Weigh the evidence and write a clear, hedged conclusion.\nQuestion: How does the Vela pulsar's spin-down rate constrain its age?"
    }
  ]

  outputs = [
    "The question asks how a neutron star's measured spin-down constrains its characteristic age. Assumption: magnetic dipole braking dominates energy loss, which is the standard textbook model.",
    "The Vela pulsar (PSR B0833-45) spins about 11.2 times per second and is among the youngest known pulsars, associated with the Vela supernova remnant in the southern sky.",
    "Characteristic age = P / (2 * P-dot). Vela's period is roughly 89 ms with a spin-down rate near 1.25e-13 s/s, giving a characteristic age of about 11,000 years — consistent with the supernova remnant's age estimates. The true age is model-dependent; glitches complicate the simple dipole picture.",
    "Vela's spin-down rate implies a characteristic age near 11,000 years, in line with the supernova remnant age. The number is an order-of-magnitude constraint, not a precise age: the magnetic dipole assumption and glitch activity set the uncertainty."
  ]

  steps.each_with_index do |attrs, index|
    run.steps.create!(attrs.merge(position: index + 1, output: outputs[index]))
  end

  run.update!(answer: outputs.join("\n\n"))
end

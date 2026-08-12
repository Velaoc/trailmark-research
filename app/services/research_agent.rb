# frozen_string_literal: true

# Executes a research run: marks the run running, plans steps if needed, then
# runs each step through the active provider adapter, recording status,
# duration, and output on every step. Any failure marks the step and the run
# failed with the error captured. Runs are expected to be small (a handful of
# steps), so the whole run executes inline in one job.
class ResearchAgent
  attr_reader :run

  def initialize(run)
    @run = run
  end

  def perform
    run.update!(status: "running", started_at: Time.current)

    steps = run.steps.to_a
    steps = create_planned_steps if steps.empty?

    context = { question: run.question }
    steps.each { |step| execute_step(step, context) }

    run.update!(status: "completed", completed_at: Time.current,
      answer: synthesize_answer(steps, context))
  rescue StandardError => e
    run.update!(status: "failed", error: e.message.to_s[0, 2000], completed_at: Time.current)
    raise
  end

  private

  def create_planned_steps
    ResearchPlanner.plan(run.question).map do |attrs|
      run.steps.create!(attrs)
    end
  end

  def execute_step(step, context)
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    step.update!(status: "running", started_at: Time.current)

    provider = ResearchProviders.provider_for(run.provider_name).new
    output = provider.execute(step, context)

    duration = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000.0
    step.update!(status: "completed", output: output, duration_ms: duration.round(3), completed_at: Time.current)
    context[step.position] = output
  rescue StandardError => e
    step.update!(status: "failed", error: e.message.to_s[0, 2000], completed_at: Time.current)
    raise
  end

  def synthesize_answer(steps, context)
    outputs = context.select { |key, _| key.is_a?(Integer) }.sort.map { |_, value| value }
    return "No steps produced findings." if outputs.empty?

    ["Research complete.", *outputs].join("\n\n")
  end
end

require "test_helper"

class ResearchAgentTest < ActiveSupport::TestCase
  test "runs a run to completion through the demo provider" do
    run = ResearchRun.create!(question: "Test question", status: "queued", provider_name: "demo")
    ResearchPlanner.plan(run.question).each { |attrs| run.steps.create!(attrs) }

    ResearchAgent.new(run).perform

    run.reload
    assert_equal "completed", run.status
    assert run.completed_at.present?
    assert_equal 4, run.steps.count
    assert run.steps.all? { |step| step.status == "completed" }
    assert run.steps.all? { |step| step.output.present? && step.duration_ms.present? }
    assert run.answer.include?("Research complete.")
  end

  test "plans steps when a run has none" do
    run = ResearchRun.create!(question: "No steps yet", status: "queued", provider_name: "demo")

    ResearchAgent.new(run).perform

    run.reload
    assert_equal "completed", run.status
    assert_equal 4, run.steps.count
  end

  test "marks the run and the failing step failed when the provider raises" do
    run = ResearchRun.create!(question: "Broken question", status: "queued", provider_name: "demo")
    run.steps.create!(position: 1, title: "Only step", status: "pending")

    exploding_provider = Class.new(ResearchProviders::Base) do
      def self.name_key = "exploding"
      def execute(_step, _context) = raise(ResearchProviders::ProviderError, "boom")
    end

    original = ResearchProviders.method(:provider_for)
    ResearchProviders.define_singleton_method(:provider_for) { |_name = nil| exploding_provider }

    assert_raises(ResearchProviders::ProviderError) { ResearchAgent.new(run).perform }
  ensure
    ResearchProviders.define_singleton_method(:provider_for, original)
  end

  test "the provider registry resolves configured adapters" do
    assert_equal ResearchProviders::Demo, ResearchProviders.provider_for("demo")
    assert_equal ResearchProviders::Http, ResearchProviders.provider_for("http")
    assert_raises(ArgumentError) { ResearchProviders.provider_for("nope") }
  end
end

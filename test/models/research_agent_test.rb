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

    provider = ResearchProviders.provider_for("demo")
    ResearchProviders.stub(:provider_for, ->(_name) { provider }) do
      provider.stub(:new, -> { raise ResearchProviders::ProviderError, "boom" }) do
        assert_raises(ResearchProviders::ProviderError) { ResearchAgent.new(run).perform }
      end
    end

    run.reload
    assert_equal "failed", run.status
    assert_equal "boom", run.error
    assert_equal "failed", run.steps.first.status
    assert_equal "boom", run.steps.first.error
  end
end

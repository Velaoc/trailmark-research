require "test_helper"

class ResearchRunsIntegrationTest < ActionDispatch::IntegrationTest
  test "root renders the new-run form" do
    get root_path

    assert_response :success
    assert_select "h1", text: /Ask a question/
    assert_select "form[action='#{research_runs_path}'] textarea[name='research_run[question]']"
  end

  test "submitting a question creates a run with planned steps and enqueues the job" do
    assert_difference -> { ResearchRun.count } => 1, -> { ResearchStep.count } => 4 do
      post research_runs_path, params: { research_run: { question: "Why is the sky dark at night?" } }
    end

    run = ResearchRun.last
    assert_equal "queued", run.status
    assert_equal "demo", run.provider_name
    assert_equal 4, run.steps.count
    assert_equal %w[pending pending pending pending], run.steps.pluck(:status)
    assert_equal 1, run.steps.first.position
    assert_enqueued_jobs 1, only: ResearchRunJob

    assert_redirected_to research_run_path(run)
    follow_redirect!
    assert_response :success
    assert_select ".md-timeline__item", count: 4
    assert_select "h1", text: /Why is the sky dark at night\?/
  end

  test "blank question is rejected" do
    assert_no_difference -> { ResearchRun.count } do
      post research_runs_path, params: { research_run: { question: "   " } }
    end

    assert_response :unprocessable_entity
    assert_select ".md-form-error"
  end

  test "completed run shows answer, step results, and durations" do
    run = ResearchRun.create!(question: "Seeded question", status: "completed", provider_name: "demo",
      answer: "The final answer.", started_at: 1.hour.ago, completed_at: 59.minutes.ago)
    run.steps.create!(position: 1, title: "Dig into evidence", status: "completed",
      input: "Find the facts.", output: "Facts found.", duration_ms: 1234.5,
      started_at: 1.hour.ago, completed_at: 59.minutes.ago)

    get research_run_path(run)

    assert_response :success
    assert_select "h1", text: /Seeded question/
    assert_select "h2", text: "Answer"
    assert_select ".md-prose", text: /The final answer\./
    assert_select ".md-timeline__item", count: 1
    assert_select "h3", text: "Dig into evidence"
    assert_select ".md-chip", text: "Done"
    assert_select ".md-timeline__duration", text: /1\.23 s/
    assert_select "summary", text: "Result"
    assert_select ".md-prose", text: /Facts found\./
  end

  test "running run shows the live refresh banner" do
    run = ResearchRun.create!(question: "Running question", status: "running", provider_name: "demo",
      started_at: Time.current)
    run.steps.create!(position: 1, title: "First step", status: "running", started_at: Time.current)

    get research_run_path(run)

    assert_response :success
    assert_select "[data-controller=refresh]"
    assert_select ".md-chip", text: "Running"
  end

  test "failed run surfaces the error" do
    run = ResearchRun.create!(question: "Failing question", status: "failed", provider_name: "demo",
      error: "provider returned HTTP 500", started_at: 1.hour.ago, completed_at: 59.minutes.ago)
    run.steps.create!(position: 1, title: "First step", status: "failed",
      error: "provider returned HTTP 500", started_at: 1.hour.ago, completed_at: 59.minutes.ago)

    get research_run_path(run)

    assert_response :success
    assert_select "h2", text: "Run failed"
    assert_select ".md-card--error", text: /provider returned HTTP 500/
  end
end

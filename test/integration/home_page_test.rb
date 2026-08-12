require "test_helper"

# The product root is the Trailmark Research new-run form. The foundation's
# generic marketing home is not mounted, so the public root must describe the
# product and offer the research entry point.
class HomePageTest < ActionDispatch::IntegrationTest
  test "root renders the product hero and the research form" do
    get root_path

    assert_response :success
    assert_select "h1", text: /Ask a question/
    assert_select "form[action='#{research_runs_path}']"
    assert_select "textarea[name='research_run[question]']"
    assert_select "input[type=submit][value='Start research']"
  end

  test "root carries the public shell: skip link, top app bar, footer legal links" do
    get root_path

    assert_response :success
    assert_select "a.md-skip-link[href='#main-content']", text: "Skip to main content"
    assert_select "header.md-top-app-bar a[href='#{root_path}']", text: Rails.configuration.x.foundation[:application_name]
    assert_select "footer.md-footer a[href='#{legal_terms_path}']", minimum: 1
    assert_select "footer.md-footer a[href='#{legal_privacy_path}']", minimum: 1
  end

  test "root shows the seeded demo run on the timeline when one exists" do
    ResearchRun.destroy_all
    run = ResearchRun.create!(question: "Demo question", status: "completed", provider_name: "demo",
      answer: "Demo answer.", started_at: 1.hour.ago, completed_at: 59.minutes.ago)
    run.steps.create!(position: 1, title: "Synthesize the answer", status: "completed",
      output: "Demo output.", duration_ms: 500, started_at: 1.hour.ago, completed_at: 59.minutes.ago)

    get root_path
    assert_response :success
    assert_select ".md-timeline__item", count: 1
    assert_select "h3", text: "Synthesize the answer"
  end
end

# frozen_string_literal: true

module ResearchStepsHelper
  STATUS_LABELS = {
    "pending" => "Pending",
    "running" => "Running",
    "completed" => "Done",
    "failed" => "Failed"
  }.freeze

  def step_status_label(step)
    STATUS_LABELS.fetch(step.status, step.status.humanize)
  end

  def duration_label(step)
    return nil if step.duration_ms.nil?

    if step.duration_ms < 1000
      "#{step.duration_ms.round(0)} ms"
    else
      format("%.2f s", step.duration_ms / 1000.0)
    end
  end
end

# frozen_string_literal: true

class ResearchStepResource < Madmin::Resource
  model ResearchStep

  attribute :id, form: false
  attribute :research_run, form: false
  attribute :position, form: false
  attribute :title, form: false
  attribute :status, form: false
  attribute :input, form: false
  attribute :output, form: false
  attribute :error, form: false
  attribute :duration_ms, form: false
  attribute :started_at, form: false
  attribute :completed_at, form: false
  attribute :created_at, form: false

  menu label: "Research Steps", parent: "Research"

  def self.display_name(record)
    "#{record.research_run_id} · #{record.position}: #{record.title}"
  end

  def self.default_sort_column = "created_at"
  def self.default_sort_direction = "desc"
end

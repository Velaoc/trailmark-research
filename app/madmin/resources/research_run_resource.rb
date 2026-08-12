# frozen_string_literal: true

class ResearchRunResource < Madmin::Resource
  model ResearchRun

  attribute :id, form: false
  attribute :question, form: false
  attribute :status, form: false
  attribute :answer, form: false
  attribute :error, form: false
  attribute :provider_name, form: false
  attribute :step_count, form: false
  attribute :started_at, form: false
  attribute :completed_at, form: false
  attribute :created_at, form: false

  scope :recent
  scope :running

  menu label: "Research Runs", parent: nil, position: 20

  def self.display_name(record)
    record.question.truncate(60)
  end

  def self.default_sort_column = "created_at"
  def self.default_sort_direction = "desc"
end

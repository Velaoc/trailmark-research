# frozen_string_literal: true

class ResearchRun < ApplicationRecord
  STATUSES = %w[queued running completed failed].freeze

  has_many :steps, -> { order(:position) }, class_name: "ResearchStep",
    dependent: :destroy, inverse_of: :research_run

  validates :question, presence: true, length: { maximum: 1000 }
  validates :status, inclusion: { in: STATUSES }

  scope :recent, -> { order(created_at: :desc).limit(20) }
  scope :running, -> { where(status: %w[queued running]) }

  def running?
    status.in?(%w[queued running])
  end

  def elapsed_ms
    return nil unless started_at

    finish = completed_at || Time.current
    (finish - started_at) * 1000.0
  end
end

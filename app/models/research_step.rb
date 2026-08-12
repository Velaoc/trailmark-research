# frozen_string_literal: true

class ResearchStep < ApplicationRecord
  STATUSES = %w[pending running completed failed].freeze

  belongs_to :research_run

  validates :title, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: STATUSES }
end

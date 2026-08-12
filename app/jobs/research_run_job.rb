# frozen_string_literal: true

class ResearchRunJob < ApplicationJob
  queue_as :default

  def perform(research_run)
    ResearchAgent.new(research_run).perform
  end
end

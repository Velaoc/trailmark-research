# frozen_string_literal: true

class ResearchRunsController < ApplicationController
  before_action :set_run, only: %i[show]

  def new
    @run = ResearchRun.new
  end

  def create
    @run = ResearchRun.new(question: params.dig(:research_run, :question)&.strip)

    if @run.valid?
      ResearchRun.transaction do
        @run.save!
        ResearchPlanner.plan(@run.question).each do |attrs|
          @run.steps.create!(attrs)
        end
      end
      @run.update!(provider_name: ResearchProviders.default_provider_name)
      ResearchRunJob.perform_later(@run)
      redirect_to @run, notice: "Research run started."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @steps = @run.steps
  end

  private

  def set_run
    @run = ResearchRun.find(params[:id])
  end
end

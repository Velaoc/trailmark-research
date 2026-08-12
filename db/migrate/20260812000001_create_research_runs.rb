# frozen_string_literal: true

class CreateResearchRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :research_runs do |t|
      t.string :question, null: false
      t.string :status, null: false, default: "queued"
      t.text :answer
      t.text :error
      t.string :provider_name
      t.datetime :started_at
      t.datetime :completed_at
      t.integer :step_count, null: false, default: 0

      t.timestamps
    end

    add_index :research_runs, :status
    add_index :research_runs, :created_at
  end
end

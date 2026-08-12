# frozen_string_literal: true

class CreateResearchSteps < ActiveRecord::Migration[8.1]
  def change
    create_table :research_steps do |t|
      t.references :research_run, null: false, foreign_key: true
      t.integer :position, null: false, default: 0
      t.string :title, null: false
      t.string :status, null: false, default: "pending"
      t.text :input
      t.text :output
      t.text :error
      t.decimal :duration_ms, precision: 12, scale: 3
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :research_steps, %i[research_run_id position], unique: true
  end
end

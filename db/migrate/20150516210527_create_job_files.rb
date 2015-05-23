class CreateJobFiles < ActiveRecord::Migration
  def change
    create_table :job_files do |t|
      t.belongs_to :job, index: true, foreign_key: true
      t.string :copy_ref
      t.string :original_path
      t.string :target_path

      t.timestamps null: false
    end
  end
end

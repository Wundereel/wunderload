class AddSizeToJobFile < ActiveRecord::Migration
  def change
    add_column :job_files, :file_size, :integer, :limit => 8
  end
end

class AddFileSizeToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :file_size, :integer, :limit => 8
  end
end

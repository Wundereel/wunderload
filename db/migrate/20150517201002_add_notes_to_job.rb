class AddNotesToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :title, :string
    add_column :jobs, :notes, :string
    add_column :jobs, :music, :string
  end
end

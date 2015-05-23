class ChangeJobNotesToText < ActiveRecord::Migration
  def up
    change_column :jobs, :notes, :text
  end

  def down
    change_column :jobs, :notes, :string
  end
end

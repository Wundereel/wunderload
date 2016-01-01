class ExtendInterestedPerson < ActiveRecord::Migration
  def change
    add_column :interested_people, :name, :string
    add_column :interested_people, :phone, :string
    add_column :interested_people, :source, :string, default: 'no_dropbox'
    add_column :interested_people, :questions, :text
  end
end

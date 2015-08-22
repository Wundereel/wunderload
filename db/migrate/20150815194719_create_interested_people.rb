class CreateInterestedPeople < ActiveRecord::Migration
  def change
    create_table :interested_people do |t|
      t.text :email

      t.timestamps null: false
    end
    add_index :interested_people, :email, unique: true
  end
end

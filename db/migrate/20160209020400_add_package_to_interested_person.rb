class AddPackageToInterestedPerson < ActiveRecord::Migration
  def change
    add_column :interested_people, :package, :string
  end
end

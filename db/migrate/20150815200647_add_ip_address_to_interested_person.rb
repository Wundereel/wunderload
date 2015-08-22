class AddIpAddressToInterestedPerson < ActiveRecord::Migration
  def change
    add_column :interested_people, :client_ip, :inet
  end
end

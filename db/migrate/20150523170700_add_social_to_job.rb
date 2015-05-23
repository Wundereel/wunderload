class AddSocialToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :names_in_reel, :text
    add_column :jobs, :share_emails, :text
  end
end

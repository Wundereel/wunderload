# == Schema Information
#
# Table name: jobs
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  title         :string
#  notes         :string
#  music         :string
#  names_in_reel :text
#  share_emails  :text
#

class Job < ActiveRecord::Base
  belongs_to :user
  has_many :files, class_name: 'JobFile', dependent: :destroy
  accepts_nested_attributes_for :files
end

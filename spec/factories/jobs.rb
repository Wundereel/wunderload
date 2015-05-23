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

FactoryGirl.define do
  factory :job do
    user nil
  end

end
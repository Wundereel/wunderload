# == Schema Information
#
# Table name: job_files
#
#  id            :integer          not null, primary key
#  job_id        :integer
#  copy_ref      :string
#  original_path :string
#  target_path   :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryGirl.define do
  factory :job_file do
    job nil
copy_ref "MyString"
original_path "MyString"
target_path "MyString"
  end

end

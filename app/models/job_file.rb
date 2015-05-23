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

class JobFile < ActiveRecord::Base
  belongs_to :job
end

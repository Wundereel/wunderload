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

require 'rails_helper'

RSpec.describe JobFile, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

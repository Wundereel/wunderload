# == Schema Information
#
# Table name: purchases
#
#  id              :integer          not null, primary key
#  job_id          :integer
#  state           :string
#  stripe_id       :string
#  stripe_token    :string
#  card_expiration :date
#  error           :text
#  fee_amount      :integer
#  amount          :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  email           :string
#

require 'rails_helper'

RSpec.describe Purchase, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

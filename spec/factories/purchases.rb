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

FactoryGirl.define do
  factory :purchase do
    job nil
state 1
stripe_id "MyString"
stripe_token "MyString"
card_expiration "2015-05-31"
error "MyText"
fee_amount 1
amount 1
  end

end

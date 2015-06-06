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

class Purchase < ActiveRecord::Base
  belongs_to :job

  include AASM

  aasm column: 'state' do
    state :pending, initial: true
    state :processing
    state :finished
    state :errored

    event :process, after: :charge_card do
      transitions from: :pending, to: :processing
    end

    event :finish do
      transitions from: :processing, to: :finished
    end

    event :fail do
      transitions from: :processing, to: :errored
    end
  end

  def charge_card
    begin
      save!
      charge = Stripe::Charge.create(
        amount: amount,
        currency: 'usd',
        source: stripe_token,
        description: email
      )
      balance = Stripe::BalanceTransaction.retrieve(charge.balance_transaction)

      update(
        stripe_id:       charge.id,
        card_expiration: Date.new(charge.card.exp_year, charge.card.exp_month, 1),
        fee_amount:      balance.fee
      )
      self.finish!
    rescue Stripe::StripeError => e
      update_attributes(error: e.message)
      self.fail!
    end
  end
end

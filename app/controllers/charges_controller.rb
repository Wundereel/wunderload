class ChargesController < ApplicationController
  layout 'bare'
  def new
    @amount = params[:amount] || '2000'
    @amount = @amount.to_i
  end

  def create
    @amount = params[:amount].to_i
    customer = Stripe::Customer.create(
      :email => params[:stripeEmail],
      :source  => params[:stripeToken]
    )

    charge = Stripe::Charge.create(
      :customer    => customer.id,
      :amount      => @amount,
      :description => 'Custom Pay',
      :currency    => 'usd'
    )

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_charge_path
  end
end

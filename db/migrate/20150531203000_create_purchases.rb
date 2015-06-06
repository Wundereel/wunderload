class CreatePurchases < ActiveRecord::Migration
  def change
    create_table :purchases do |t|
      t.references :job, index: true, foreign_key: true
      t.string :state
      t.string :stripe_id
      t.string :stripe_token
      t.date :card_expiration
      t.text :error
      t.integer :fee_amount
      t.integer :amount

      t.timestamps null: false
    end
  end
end

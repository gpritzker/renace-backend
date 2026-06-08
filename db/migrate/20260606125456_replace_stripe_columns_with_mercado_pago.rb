class ReplaceStripeColumnsWithMercadoPago < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :stripe_customer_id, :string
    rename_column :users, :stripe_subscription_id, :mp_subscription_id
  end
end

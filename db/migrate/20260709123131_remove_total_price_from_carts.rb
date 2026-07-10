class RemoveTotalPriceFromCarts < ActiveRecord::Migration[7.1]
  def change
    remove_column :carts, :total_price, :decimal
  end
end

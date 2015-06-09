class AddValueToPricePerSqFoot < ActiveRecord::Migration
  def change
    add_column :price_per_sqfts, :value, :decimal
  end
end

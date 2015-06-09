class CreatePricePerSqfts < ActiveRecord::Migration
  def change
    create_table :price_per_sqfts do |t|
      t.references :location, index: true
      t.integer :price
      t.integer :sqft

      t.timestamps null: false
    end
    add_foreign_key :price_per_sqfts, :locations
  end
end

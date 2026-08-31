class CreateParts < ActiveRecord::Migration[7.2]
  def change
    create_table :parts do |t|
      t.string :name, null: false
      t.string :sku, null: false
      t.decimal :unit_price, precision: 12, scale: 2, null: false
      t.integer :stock_quantity, null: false, default: 0
      t.integer :minimum_stock, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :parts, :sku, unique: true
  end
end

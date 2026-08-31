class CreateServiceOrderItems < ActiveRecord::Migration[7.2]
  def change
    create_table :service_order_items do |t|
      t.references :service_order, null: false, foreign_key: true
      t.string :item_type, null: false
      t.references :catalog_service, foreign_key: true
      t.references :part, foreign_key: true
      t.string :description, null: false
      t.integer :quantity, null: false, default: 1
      t.decimal :unit_price, precision: 12, scale: 2, null: false
      t.decimal :total_price, precision: 12, scale: 2, null: false
      t.timestamps
    end
  end
end

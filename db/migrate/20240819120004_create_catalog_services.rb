class CreateCatalogServices < ActiveRecord::Migration[7.2]
  def change
    create_table :catalog_services do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 12, scale: 2, null: false
      t.boolean :active, null: false, default: true
      t.timestamps
    end
  end
end

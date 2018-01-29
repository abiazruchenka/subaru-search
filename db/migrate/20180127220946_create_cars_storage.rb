class CreateCarsStorage < ActiveRecord::Migration[5.1]
  def change
    create_table :cars_storages do |t|
      t.string :url
      t.string :model
      t.string :price
      t.datetime :updated_at
      t.string :status
      t.string :page
      t.string :image
      t.timestamps null: false
    end
  end
end

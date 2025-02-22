class CreateSimulations < ActiveRecord::Migration[6.1]
  def change
    create_table :simulations do |t|
      t.string :code
      t.integer :user_id
      t.timestamps null: false
    end
  end
end
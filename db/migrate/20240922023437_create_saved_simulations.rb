class CreateSavedSimulations < ActiveRecord::Migration[6.1]
  def change
    create_table :saved_simulations do |t|
      t.integer :user_id
      t.string :title
      t.string :simulation_type
      t.json :variables
      t.timestamps null: false
    end
  end
end

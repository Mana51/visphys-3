class CreateSharedSimulations < ActiveRecord::Migration[6.1]
  def change
    create_table :shared_simulations do |t|
      t.integer :user_id
      t.string :title
      t.string :simulation_type
      t.json :variables
      t.string :token
      t.timestamps null: false
    end

    add_index :shared_simulations, :token, unique: true
  end
end

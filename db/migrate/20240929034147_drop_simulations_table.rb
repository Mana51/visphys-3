class DropSimulationsTable < ActiveRecord::Migration[6.1]
  def up
    drop_table :simulations if table_exists?(:simulations)
  end

  def down
    create_table :simulations do |t|
      t.string :code
      t.integer :user_id
      t.timestamps null: false
    end
  end
end

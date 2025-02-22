class AddTitleToSimulations < ActiveRecord::Migration[6.1]
  def change
    add_column :simulations, :title, :string
  end
end

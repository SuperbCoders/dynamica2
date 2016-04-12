class AddCurrencyToProject < ActiveRecord::Migration
  def change
    add_column :projects, :currency, :string, limit: 4, default: 'USD'
  end
end

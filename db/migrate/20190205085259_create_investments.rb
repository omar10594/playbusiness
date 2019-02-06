class CreateInvestments < ActiveRecord::Migration[5.2]
  def change
    create_table :investments do |t|
      t.integer :amount
      t.integer :wallet_amount, default: 0
      t.references :startup, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end

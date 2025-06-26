class CreateUserIndustries < ActiveRecord::Migration[8.0]
  def change
    create_table :user_industries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :industry, null: false, foreign_key: true
      t.integer :ordering

      t.timestamps
    end
  end
end

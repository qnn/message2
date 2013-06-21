class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :name
      t.integer :gender
      t.string :phone_number
      t.integer :qq_number
      t.string :title
      t.text :content

      t.timestamps
    end
  end
end

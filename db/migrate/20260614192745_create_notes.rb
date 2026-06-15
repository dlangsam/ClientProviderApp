class CreateNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :notes do |t|
      t.references :client, null: false, foreign_key: true
      t.text :content, null: false

      t.timestamps
    end

    add_index :notes, :created_at
  end
end

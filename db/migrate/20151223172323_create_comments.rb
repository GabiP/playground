class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :project, index: true, foreign_key: true, null: false
      t.references :author, references: :user, index: true, foreign_key: true, null: false
      t.text :text, null: false

      t.timestamps null: false
    end
  end
end

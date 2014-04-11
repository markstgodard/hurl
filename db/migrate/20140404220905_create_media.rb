class CreateMedia < ActiveRecord::Migration
  def change
    create_table :media do |t|
      t.string :name
      t.string :full_name
      t.string :poster
      t.string :art
      t.string :banner
      t.string :media_type
      t.string :genre
      t.integer :year
      t.text :overview
      t.integer :rating
      t.integer :runtime

      t.timestamps
    end
  end
end

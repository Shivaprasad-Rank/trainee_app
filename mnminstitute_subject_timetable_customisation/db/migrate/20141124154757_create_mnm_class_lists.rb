class CreateMnmClassLists < ActiveRecord::Migration
  def self.up
    create_table :mnm_class_lists do |t|
      t.integer :subject_id
      t.integer :mnm_shared_subject_id
      t.string :subject_name
      t.integer :school_id
      t.timestamps
    end
  end

  def self.down
    drop_table :mnm_class_lists
  end
end

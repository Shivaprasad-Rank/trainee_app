class CreateMnmSharedSubjectAssociations < ActiveRecord::Migration
  def self.up
    create_table :mnm_shared_subject_associations do |t|
      t.integer :mnm_shared_subject_id
      t.integer :subject_id
      t.integer :batch_id
      t.integer :school_id
      t.timestamps
    end
  end

  def self.down
    drop_table :mnm_shared_subject_associations
  end
end

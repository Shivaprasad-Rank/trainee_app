class CreateMnmSubjectComments < ActiveRecord::Migration
  def self.up
    create_table :mnm_subject_comments do |t|
      t.integer :subject_id
      t.integer :mnm_shared_subject_id
      t.text    :subject_comment
      t.integer :author_id
      t.boolean :is_approved
      t.integer :school_id
      t.timestamps
    end
  end

  def self.down
    drop_table :mnm_subject_comments
  end
end

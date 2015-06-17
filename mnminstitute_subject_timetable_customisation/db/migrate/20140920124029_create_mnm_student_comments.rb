class CreateMnmStudentComments < ActiveRecord::Migration
  def self.up
    create_table :mnm_student_comments do |t|
      t.integer :student_id
      t.text :content
      t.integer :author_id
      t.boolean :is_approved
      t.integer :school_id
      t.timestamps
    end
  end

  def self.down
    drop_table :mnm_student_comments
  end
end

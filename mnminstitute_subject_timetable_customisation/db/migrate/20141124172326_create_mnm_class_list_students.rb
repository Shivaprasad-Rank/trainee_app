class CreateMnmClassListStudents < ActiveRecord::Migration
  def self.up
    create_table :mnm_class_list_students do |t|
      t.integer :student_id
      t.integer :mnm_class_list_id
      t.integer :school_id
      t.timestamps
    end
  end

  def self.down
    drop_table :mnm_class_list_students
  end
end

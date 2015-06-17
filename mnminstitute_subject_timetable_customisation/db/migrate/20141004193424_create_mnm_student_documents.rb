class CreateMnmStudentDocuments < ActiveRecord::Migration
  def self.up
    create_table :mnm_student_documents do |t|
      t.integer :student_id
      t.integer :author_id

      t.string :document_file_name
      t.string :document_content_type
      t.binary :document_data, :limit => 75.kilobytes
      t.integer :document_file_size
      t.integer :school_id
      t.timestamps
    end
  end

  def self.down
    drop_table :mnm_student_documents
  end
end

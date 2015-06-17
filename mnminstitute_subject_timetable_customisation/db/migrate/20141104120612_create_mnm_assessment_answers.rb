class CreateMnmAssessmentAnswers < ActiveRecord::Migration
  def self.up
    create_table :mnm_assessment_answers do |t|
      t.integer :assignment_id
      t.integer :assignment_answer_id
      t.integer :student_id
      t.text   :assessment_comment
      t.integer :author_id
      t.boolean :is_approved
      t.integer :school_id
      t.timestamps
    end
  end

  def self.down
    drop_table :mnm_assessment_answers
  end
end

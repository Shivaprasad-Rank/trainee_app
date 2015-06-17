class MnmStudentComment < ActiveRecord::Base

  validates_presence_of :content, :author_id, :student_id, :is_approved
  belongs_to :student
  belongs_to :author, :class_name => 'User'
  
end

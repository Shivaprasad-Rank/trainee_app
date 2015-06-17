 class CoursesStudent < ActiveRecord::Base
  belongs_to :student, :foreign_key => 'student_id'
  belongs_to :course, :foreign_key => 'course_id'
end

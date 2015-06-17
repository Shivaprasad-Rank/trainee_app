class MnmAssessmentAnswer < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :assignment_answer
  belongs_to :author, :class_name => 'User'
end

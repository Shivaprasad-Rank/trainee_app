class MnmSubjectComment < ActiveRecord::Base
  belongs_to :subject
  belongs_to :mnm_shared_subject
  belongs_to :author, :class_name => 'User'
end

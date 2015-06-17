class MnmSharedSubjectAssociation < ActiveRecord::Base
  belongs_to :subject, :foreign_key => 'subject_id'
  belongs_to :mnm_shared_subject, :foreign_key => 'mnm_shared_subject_id'

end

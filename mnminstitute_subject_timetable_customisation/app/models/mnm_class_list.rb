class MnmClassList < ActiveRecord::Base
  validates_presence_of :subject_id, :subject_name
  belongs_to :course
  belongs_to :batch
  has_many :students
  has_many :subjects
  has_many :mnm_shared_subjects
  
end

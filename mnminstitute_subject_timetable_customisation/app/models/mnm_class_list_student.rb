class MnmClassListStudent < ActiveRecord::Base
  has_many :students
  has_many :subjects
  has_many :mnm_shared_subjects
end

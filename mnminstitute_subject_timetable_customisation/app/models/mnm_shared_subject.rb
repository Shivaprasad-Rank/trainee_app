class MnmSharedSubject < ActiveRecord::Base
  has_many :subjects
  has_many :mnm_subject_documents
  has_many :mnm_subject_comments
  validates_presence_of :name, :code
  validates_uniqueness_of :code
end

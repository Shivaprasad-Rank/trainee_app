class MnmSubjectDocument < ActiveRecord::Base
  belongs_to :subject
  belongs_to :author, :class_name => 'User'
  belongs_to :mnm_shared_subject
  has_attached_file :document,
    :url => "/system/:class/:attachment/:id/:style/:basename.:extension",
    :path => ":rails_root/public/system/:class/:attachment/:id/:style/:basename.:extension"
  validates_attachment_presence :document

  VALID_TYPES = ['audio/mp4', 'video/mp4', 'application/pdf', 'image/jpeg']

  validates_attachment_content_type :document, :content_type =>VALID_TYPES,
    :message=>'Image can only be pdf, jpeg, mp4',:if=> Proc.new { |d| !d.document_file_name.blank? }

  # validates_attachment_content_type :document, :content_type=>['image/jpg', 'application/pdf', 'image/mp4']

  validates_attachment_size :document, :less_than => 52428800,\
    :message=>'must be less than 50 MB.',:if=> Proc.new { |p| p.document_file_name_changed? }

  def download_allowed_for user
    return true if user.admin?
    return true if user.employee?
    false
  end
end

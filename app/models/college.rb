class College < ActiveRecord::Base
	 has_many :students #1 to many relationships
     mount_uploader :image, ImageUploader
	validates_presence_of :colname
	validates_presence_of :coladd
end

class Student < ActiveRecord::Base
	#atte_accessible :student_id ,:name,:image_filename,:remote_image_url
	#belongs_to :students
	#1 to many Model relationship
	belongs_to :college, :foreign_key => 'college_id'#1 to many Model relationship
	#1 to 1 Model relationship
	belongs_to :studentid
	
	has_many :courses_students
    has_many :courses, :through => :courses_students#many to many model relationships

	mount_uploader :image_filename, ImageUploader
	validates_presence_of :name 
		validates :phone,:presence => {:message => 'hello world, bad operation!'},
                     :numericality => true,
                     :length => { :minimum => 10, :maximum => 15 }
	validates_numericality_of :age
	validates_presence_of :address
	validates  :email , :presence => true ,
	:length => {:minimum => 3,:maximum => 254},
	:format => {:with => /\A^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$\z/i}
	
end

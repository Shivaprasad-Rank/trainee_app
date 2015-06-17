class Course < ActiveRecord::Base

	has_many :courses_students
    has_many :students, :through => :courses_students

    validates_presence_of :cname 
    validates_presence_of :cdesc

end

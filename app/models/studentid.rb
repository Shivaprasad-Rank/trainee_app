class Studentid < ActiveRecord::Base
	has_one :student
	validates_presence_of :idcards 
	validates_presence_of :descp
end

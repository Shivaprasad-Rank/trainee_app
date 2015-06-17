class StudentMailer < ActionMailer::Base
  default from: "from@example.com"

   def new_student(student)
    @student = student
    
    @url = "http://localhost:3000/"
    mail(:from => "noreply@student.com", :to => @student.email, :subject => "Welcome to our Application")
  end

end

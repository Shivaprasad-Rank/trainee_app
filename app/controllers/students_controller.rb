class StudentsController < ApplicationController
 before_action :authenticate_user!
  def index
    @students = Student.all
  end
  
  def new
  	@student = Student.new
    @studentids = Studentid.all
    
  end

  def create
    @student = Student.new(student_params)
    @studentids = Studentid.all
    puts "<<<<<<<<<<<<<<<<<<<student_params<<<<<<<<<<<"
    puts params[:student].inspect
    if @student.save
    	 redirect_to students_path
       
    else
    	 render :action => "new"
    end
  end
 
  def edit
    @student = Student.find(params[:id])
    @studentids = Studentid.all
  end 

  def update 
    @student = Student.find(params[:id])
    @studentids = Studentid.all
      if @student.update_attributes(student_params)
          redirect_to student_path(@student.id)
        else
          render :action => "edit"
        end
    end
  def show
    @student = Student.find(params[:id])
    @courses = Course.all                                                                                                                                                                                                                                                                                                      
  end

  def destroy
    @student = Student.find(params[:id])
    if @student.delete
       redirect_to students_path
    end
  end

def assign_courses
    @student=Student.find(params[:id])
    puts "<<<<<<<<<<<<params[:course_ids]<<<<<<<<<<<<<"
    puts params[:course_ids].inspect
    if !params[:course_ids].empty?
        params[:course_ids].each do |course_id| 
        @courses_student = CoursesStudent.new(:student_id => @student.id,:course_id => course_id)
        @courses_student.save
    end
    else
      flash[:error]="error"
    end
      redirect_to students_path
end

def send_mail
 @student = Student.find(params[:id])
 if StudentMailer.new_student(@student).deliver
      message = "<span style='color: green'>Mail Sent</span>"
    else
      message = "<span style='color: red'>Error</span>"
    end
    render :text => message
end
def update_status
    @student = Student.find(params[:id])
    puts "<<<<<<<<<<<<javscrit<<<<<<<<<<<<<"

    if @student and @student.update_attributes(:status => params[:status])
      message = "<span style='color: green'>Updated</span>"
    else
      message = "<span style='color: red'>Error</span>"
    end
    render :text => message
  end
  



  private

  def student_params
    params.require(:student).permit(:image_filename,:name, :age, :address, :phone, :email ,:gender,:college_id,:studentid_id ,:status)
  end

end

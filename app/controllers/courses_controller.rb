class CoursesController < ApplicationController
	before_action :authenticate_user!
  def index
		  @courses = Course.all
	end
	
  def new 
		  @course = Course.new
    end
  def create 
         @course = Course.new(course_params)
	      puts params[:course].inspect
	       puts params[:course][:image].inspect
	 if @course.save
		  redirect_to course_path(@course.id)
	 else
		 render :action => "new"
	 end
   end
   def edit
          @course = Course.find(params[:id])
   end
  def update
          @course = Course.find(params[:id])
          puts params[:course][:image].inspect
      if @course.update_attributes(course_params)
      	  redirect_to course_path(@course.id)
	 else
		  render :action => "edit"
	 end
    end
    def show
	 @course = Course.find(params[:id])
    end

    def destroy 
	     @course = Course.find(params[:id])
	 if @course.delete
		 redirect_to courses_path
     end
    end

    
    private

    def course_params
	    params.require(:course).permit(:cname, :cdesc)
    end
end




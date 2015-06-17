class CollegesController < ApplicationController
    
    before_action :authenticate_user!
    def index
    @colleges = College.all
    end

    def new
  	@college = College.new
    end

    def create
    @college = College.new(college_params)
     ## puts params[:college].inspect
    if @college.save
    	redirect_to colleges_path
    else
    	render :action => "new"
    end
    end
 
     def edit
    @college = College.find(params[:id])
    end 

      def update 
    @college = College.find(params[:id])
      if @college.update_attributes(college_params)
          redirect_to college_path(@college.id)
        else
          render :action => "edit"
        end
    end

 def show
    @college = College.find(params[:id])
 end

def destroy
  @college = College.find(params[:id])
  if @college.delete
    redirect_to colleges_path
  end
end
 private

  def college_params
    params.require(:college).permit(:colname,:image,:coladd)
  end
end

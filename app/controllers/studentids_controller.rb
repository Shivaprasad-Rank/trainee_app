class StudentidsController < ApplicationController
 before_action :authenticate_user!
 def index
    @studentids = Studentid.all
  end

  def new
  	@studentid = Studentid.new
  end

  def create
    @studentid = Studentid.new(student_params)
    puts params[:studentid].inspect
    if @studentid.save
    	redirect_to studentids_path
    else
    	render :action => "new"
    end
  end
 
 def edit
    @studentid = Studentid.find(params[:id])
  end 
 def update 
    @studentid = Studentid.find(params[:id])
      if @studentid.update_attributes(student_params)
          redirect_to studentid_path(@studentid.id)
        else
          render :action => "edit"
        end
    end
 def show
    @studentid = Studentid.find(params[:id])
 end

def destroy
  @studentid = Studentid.find(params[:id])
  if @studentid.delete
    redirect_to studentids_path
  end
end

  private

  def student_params
    params.require(:studentid).permit(:idcards, :descp)
  end
end


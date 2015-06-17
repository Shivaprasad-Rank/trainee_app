class FileUploadsController < ApplicationController
def index
	@files = FileUpload.all
	end
	def new
		@file = FileUpload.new
	end

end

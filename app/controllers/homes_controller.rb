class HomesController < ApplicationController

def index
 if user_signed_in?
 	redirect_to :controller=>'students',:action => 'index'
end
end
	def new
	end
	def show
	
	end
 
def admonk_upload

	file_data = params[:uploaded_file]
	if file_data.respond_to?(:read)
	xml_contents = file_data.read
	elsif file_data.respond_to?(:path)
	xml_contents = File.read(file_data.path)
	else
	logger.error "Bad file_data: #{file_data.class.name}: #{file_data.inspect}"
	end
	my_match = /<body>/.match(xml_contents) 
	p_match = my_match.post_match
	n_match = /<\/body>/.match(p_match)
	@o_match = n_match.pre_match
	puts "////////////////////////#{@o_match.inspect}"

	# cod = xml_contents.encoding
	#  puts "////////////////////#{cod.inspect}"
	
	#reg = /<body[^>]*>(.*?)<\/body>/is
	#  doc = reg.encoding
	# puts "////////////////////#{doc.inspect}"
 #     	 @h_body = reg.match(xml_contents)
	# 	puts "AAAAAAAAAAAAAAAAAA#{@h_body.inspect}"
	# cod = xml_contents.encoding
	# puts "////////////////////#{cod.inspect}"
	# doc = xml_contents.force_encoding('UTF-8')
	# puts doc.inspect
	  #doc = xml_contents.force_encoding('ASCII-8BIT').force_encoding('UTF-8')
     #puts "////////////////////#{doc.inspect}"

     	
      # rec = reg.encoding
      # puts "////////////////////#{rec.inspect}"
     #reg = Regexp.new("a".force_encoding("UTF-8")).encoding
     #reg = Regexp.new("a".force_encoding("UTF-8"), Regexp::FIXEDENCODING).encoding
     
     #reg = Regexp.new sreg.encode(‘UTF-8′), Regexp::IGNORECASE | Regexp::MULTILINE, ‘n’
	 #reg = Regexp.new sreg.encode(‘UTF-8′), *any option*, ‘**any option**’
    
	#xml_contents.lines do |l|
		#puts "AAAAAAAAAAAAAA#{l.inspect}"
  		#l.match("/.*<\s*body[^>]*>)/|/(<\s*/\s*body\s*\>.+/", $html, $matches);
	#xml_contents.match("/<body[^>]*>(.*?)<\/body>/is",$matches)
	#end
	puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
	puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

	puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
	#puts $matches[1].inspect
	puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

end
end

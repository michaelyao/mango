require 'rubygems'
require 'open-uri'
require 'hpricot'

@url = "http://www.redfin.com/CA/Los-Altos-Hills/28333-Christopher-Ln-94022/home/1350997"
@response = ''

begin
  # open-uri RDoc: http://www.redfin.com/CA/San-Jose/755-Cascade-Dr-95129/home/800939
  open(@url, "User-Agent" => "Ruby/#{RUBY_VERSION}",
    "From" => "email@addr.com",
    "Referer" => "http://www.redfin.com/CA/Los-Altos-Hills/28333-Christopher-Ln-94022/home/1350997") { |f|
                  
    puts "Fetched document: #{f.base_uri}"
    puts "\t Content Type: #{f.content_type}\n"
    puts "\t Charset: #{f.charset}\n"
    puts "\t Content-Encoding: #{f.content_encoding}\n"
    puts "\t Last Modified: #{f.last_modified}\n\n"
                
    # Save the response body
    @response = f.read
  }
    
  # HPricot RDoc: http://code.whytheluckystiff.net/hpricot/
  doc = Hpricot(@response)
 
 #puts (doc/"/html/body/div/div[3]/div[4]/div/div/div[2]/div[2]/table/tr/td").inner_html

  # Pull out all other posted stories and date posted
  (doc/"/html/body/div/div[3]/div[4]/div/div/div[2]/div[2]/table/tr").each do |row|
    cells=[]
    name=""
    value=""
    (row/"td").each do |cell|
        
        #puts (cell[:class])

	if ((cell[:class]).strip == "property_detail_label left_column")
          name = cell.inner_html.strip.chomp(':')
	  #print "[#{cell.inner_html.strip}]"
        else
          if( name == "Status" or name =="County")
	    value = (cell/"a").inner_html.strip
          elsif ( name == "Lot Size" )
	    value = cell.inner_html.strip
	    value = value.gsub! /\t/, ''
            value = value.gsub! /\n/, ''
 	    #value = value.gsub! /\r/, ''
          else
            value = cell.inner_html.strip
          end
	  print "[#{name}]=#{value}\n"
	end

    end
  end
    
   puts (doc/"//*[@id=\"property_description\"]").inner_html.strip 
    
   (doc/"/html/body/div/div[3]/div[4]/div/div[2]/div/div/div/div").each  do |amenity_set|
      
      if( amenity_set.attributes['class'] == "amenity_set")
        puts "\n" + (amenity_set/"h4").inner_html.strip
        ( amenity_set/"*/li").each do |amen|
            puts "\t#{amen.inner_html.strip}"
        end
        if (amenity_set/"div").length > 0 #&& (amenity_set/"div").attributes['id']== "last_updated_date"
          puts "\t#{(amenity_set/"div").inner_html.strip}" 
        end     
      end
    end
    
    puts (doc/"//*[@id=\"thumbnail_page_control_0\"]").inner_html
   
rescue Exception => e
  print e, "\n"
end


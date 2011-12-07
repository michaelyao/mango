require 'rubygems'
require 'open-uri'
require 'hpricot'

@url = "http://www.redfin.com/city-homes-for-sale/117/CA/Alameda?start=200"
@response = ''

begin
  # open-uri RDoc: http://www.redfin.com/city/117/CA/Alameda
  open(@url, "User-Agent" => "Ruby/#{RUBY_VERSION}",
    "From" => "email@addr.com",
    "Referer" => "http://www.redfin.com/city/117/CA/Alameda") { |f|
    puts "Status code: #{f.status}"              
    puts "Fetched document: #{f.base_uri}"
    puts "\t Content Type: #{f.content_type}\n"
    puts "\t Charset: #{f.charset}\n"
    puts "\t Content-Encoding: #{f.content_encoding}\n"
    puts "\t Last Modified: #{f.last_modified}\n"
    puts "\t Length: #{f.length}\n\n"
                
    # Save the response body
    @response = f.read
  }
    
  # HPricot RDoc: http://code.whytheluckystiff.net/hpricot/
  doc = Hpricot(@response)
 
  # Pull out all other posted stories and date posted
  (doc.search("//div[@class='listing_address']") ).each do |row|
    if (row/"a").length > 0
       address=(row/"a").inner_html.strip
       listing_link=(row/"a").first[:href].strip

        listing_date = row.parent.next_sibling.inner_html.strip
        puts "Address: #{address}  Listing Link: #{listing_link}   Listing Date:#{listing_date}\n"
    end
 end

   
rescue Exception => e
  print e, "\n"
end


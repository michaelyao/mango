require 'rubygems'
require 'open-uri'
require 'hpricot'

@url = "http://www.redfin.com/cities/2/sanfrancisco"
@response = ''

begin
  # open-uri RDoc: http://www.redfin.com/cities/2/sanfrancisco
  open(@url, "User-Agent" => "Ruby/#{RUBY_VERSION}",
    "From" => "email@addr.com",
    "Referer" => "http://www.redfin.com/cities/2/sanfrancisco") { |f|
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
 
 #puts (doc/"/html/body/div/div[3]/div[4]/div/div[2]/table").inner_html
 puts (doc/"/html/body/div/div[3]/div[4]/div/div[2]/table/*/tr").count
  # Pull out all other posted stories and date posted
  (doc/"/html/body/div/div[3]/div[4]/div/div[2]/table/*/tr").each do |row|
    cells=[]
    name=""
    city_link=""
    median_list=""
    median_sqft=""
    sale_list=""
    homes=""
    home_for_sale=""
    neighbor_zip=""
    neighbor_zip_name=""
    
 #   puts row.inner_html
    
    count = 0
    (row/"td").each do |cell|
        case count
          when 0
            name = (cell/"a").inner_html.strip.chomp('Real Estate').strip
            city_link = (cell/"a").first[:href].strip
          when 1
            median_list = cell.inner_html.strip
          when 2
            median_sqft = cell.inner_html.strip
          when 3
            sale_list = cell.inner_html.strip
          when 4
            homes = (cell/"a").inner_html.strip
            home_for_sale = (cell/"a").first[:href].strip
          when 5
            neighbor_zip = (cell/"a").first[:href].strip
            neighbor_zip_name = (cell/"a").inner_html.strip
        end
        count = count + 1
    end
        puts "City Name: #{name}\n"
        puts "\t City Link: #{city_link}\n"
        puts "\t Median List: #{median_list}\n"
        puts "\t Median_sqft: #{median_sqft}\n"
        puts "\t Sale_list: #{sale_list}\n" 
        puts "\t Homes: #{homes}\n"
        puts "\t Homes for Sale: #{home_for_sale}\n"
        puts "\t Neighbor_zip_name: #{neighbor_zip_name}\n"
        puts "\t Neighbor_zip: #{neighbor_zip}\n"
 end

   
rescue Exception => e
  print e, "\n"
end


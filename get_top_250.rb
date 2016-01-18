#!/usr/bin/ruby
#

require 'nokogiri'
require 'open-uri'

DOWNLOADS_PATH='/Users/ian.shaw/Downloads'

def get_top_250()
  #remove the existing version
  File.delete("current_top250.lst")

  #Collect the page html source
  page = Nokogiri::HTML(open("http://www.imdb.com/chart/top"))

  #Return only elements which are part of the titleColumn css class.
  results = page.css('.titleColumn')

  #Loop through each row found.
  results.each do |result|
    result.css('i').each do |i|
      i.content = ''
    end

  #remove lines with no content
  no_blanks = result.text.gsub /^$\n/, ''

  #remove a bunch of blank space at the beginning of each line
  without_lead = no_blanks.gsub(/\n/,'')[14..-1]

  #removes any leading whitespace
  without_wlead = without_lead.lstrip.chop

  #removes trailing whitespace
  without_trail = without_wlead.sub(/\s+\Z/, "")

  #Removes the last word of each line
  without_year = without_trail[/(.*)\s/,1]
  
  #output the result to a file, with one record per line
  output = File.new("current_top250.lst", "a")
  output << without_year+"\n"
  output.close
  end
end

def get_current_inventory
  #Get a list of video type files from the #{DOWNLOADS_PATH}
  inventory = `file --mime-type  #{DOWNLOADS_PATH}/*  | grep video  | sed -e 's/\.[^.]*$//' -e 's@.*/@@'`

  #Write that to a file named inventory.lst
  output = File.new("inventory.lst", "w")
  output.syswrite(inventory)
  output.close
end

def compare_inventory_to_top250
  #Compare the two files we've created, by shelling out to bash and using the diff tool
  result = `diff current_top250.lst inventory.lst | grep '^<' | sed 's/^..//'`
  puts result
end

get_top_250
get_current_inventory
compare_inventory_to_top250

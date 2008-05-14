#!/usr/bin/env ruby
#
#  Created by Jonathan Lim on 2008-05-13.
#  Copyright (c) 2008. All rights reserved.

# Twitter pollen updates

# $: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'open-uri'
gem 'twitter4r'
require 'twitter'
require 'hpricot'

twitter = Twitter::Client.new(:login => 'pollen_london', :password => 'secrety password')

# where I live
PLACE = "London"

# load BBC Pollen site
doc = Hpricot(open("http://www.bbc.co.uk/weather/pollen/"))

elements = doc.search("/html/body/table/tbody/tr/td/img")

to_twitter = []

elements.each do |image|
  alt_text = image.get_attribute("alt")
  to_twitter << alt_text if alt_text.include?(PLACE)
end

to_twitter.each do |update|
  begin
    twitter.status(:post, update)
  rescue Exception => e
    puts "FAILED!"
    puts e
    exit 1
  end
end
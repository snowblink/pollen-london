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
require 'yaml'

Twitter::Client.configure do |conf|
  conf.application_name     = 'PollenLondonBot'
  conf.application_version  = '0.3'
  conf.application_url      = 'https://github.com/snowblink/pollen-london/tree'
  conf.source               = 'pollenlondon'
end

twitter_config = YAML::load_file(File.dirname(__FILE__) + '/twitter_config.yml')
twitter = Twitter::Client.new(twitter_config)

date = DateTime.now.strftime("%Y%m%d%H%M%S")

# where I live
PLACE = "London"

# load BBC Pollen site
doc = Hpricot(open("http://www.bbc.co.uk/weather/pollen/"))

elements = doc.search("/html/body/table/tbody/tr/td/img")

to_twitter = []

elements.each do |image|
  alt_text = image.get_attribute("alt")
  if alt_text.include?(PLACE)
    to_twitter << "#{alt_text} checked at #{date}"
  end
end

to_twitter.each do |update|
  begin
    twitter.status(:post, update)
    # puts update
  rescue Exception => e
    puts "FAILED!"
    puts e
    exit 1
  end
end
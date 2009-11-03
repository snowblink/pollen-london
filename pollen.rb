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
  conf.application_version  = '0.5'
  conf.application_url      = 'https://github.com/snowblink/pollen-london/tree'
  conf.source               = 'pollenlondon'
end

twitter_config = YAML::load_file(File.dirname(__FILE__) + '/twitter_config.yml')
twitter = Twitter::Client.new(twitter_config)

date = DateTime.now.strftime("%A %Y%m%d")

# load BBC Pollen site
doc = Hpricot(open("http://news.bbc.co.uk/weather/forecast/8/UV.xhtml"))

elements = doc.search("li")
to_twitter = []

# 20091103 - Adding type of pollen based on time of year
# Tree pollen forecasts from the 20th April to 19th May.
# Grass pollen forecasts from the 20th May to 4th August.
# Weed pollen forecasts from the 5th to 25th August.
# Fungal Spore forecasts from the 25th August to 30th November. 

pollen_type = if ((Date.civil(Date.today.year, 4, 20))..(Date.civil(Date.today.year, 5, 19))).include?(Date.today)
  "Tree Pollen"
elsif ((Date.civil(Date.today.year, 5, 20))..(Date.civil(Date.today.year, 8, 4))).include?(Date.today)
  "Grass Pollen"
elsif ((Date.civil(Date.today.year, 8, 5))..(Date.civil(Date.today.year, 8, 25))).include?(Date.today)
  "Weed Pollen"
elsif ((Date.civil(Date.today.year, 8, 25))..(Date.civil(Date.today.year, 11, 30))).include?(Date.today)
  "Fungal Spore"
end

if pollen_type.nil?
  # Outside of pollen season
else
  
  elements.each do |element|
    if element.get_attribute("class") == 'pollenval'
      to_twitter << element.at("img").get_attribute("alt") + " #{pollen_type} (" + Time.now.gmtime.strftime("%a %d/%m") + ')'
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
end

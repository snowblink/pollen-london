#!/usr/bin/env ruby
#
#  Created by Jonathan Lim on 2008-05-13.
#  Copyright (c) 2008. All rights reserved.

# Twitter pollen updates

# $: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require "rubygems"
require "bundler/setup"

require 'open-uri'
require 'twitter'

require 'hpricot'
require 'yaml'

Twitter::Client.configure do |conf|
  conf.application_name       = 'PollenLondonBot'
  conf.application_version    = '0.6'
  conf.application_url        = 'https://github.com/snowblink/pollen-london/tree'
  conf.source                 = 'pollenlondon'
end

twitter = Twitter::Client.from_config(File.join(File.dirname(__FILE__), 'twitter.yml'), 'production')

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

elements.each do |element|
  if element.get_attribute("class") == 'pollenval'
    next unless element.at("img")
    low_or_high = element.at("img").get_attribute("alt")
    next if low_or_high =~ /N\/A/
    to_twitter << low_or_high
    to_twitter << pollen_type unless pollen_type.nil?
    to_twitter << "(" + Time.now.gmtime.strftime("%a %d/%m") + ')'
  end
end

unless to_twitter.empty?
  begin
    twitter.status(:post, to_twitter.join(' '))
    # puts to_twitter.join(' ')
  rescue Exception => e
    puts "FAILED!"
    puts e.backtrace
    exit 1
  end
end

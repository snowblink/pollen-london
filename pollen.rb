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
  conf.application_version  = '0.4'
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

elements.each do |element|
  if element.get_attribute("class") == 'pollenval'
    to_twitter << element.at("img").get_attribute("alt") + ' (' + Time.now.strftime("%a %d/%m") + ')'
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
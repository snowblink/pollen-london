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

Twitter.configure do |config|
  twitter_config = YAML.load_file('twitter.yml')

  config.consumer_key = twitter_config["oauth_consumer"]["key"]
  config.consumer_secret = twitter_config["oauth_consumer"]["secret"]
  config.oauth_token = twitter_config["oauth_access"]["key"]
  config.oauth_token_secret = twitter_config["oauth_access"]["secret"]
end

date = DateTime.now.strftime("%A %Y%m%d")

# load BBC Pollen site
doc = Hpricot(open("http://www.bbc.co.uk/weather/2643743"))

pollen_value = doc.at("div.pollen-index span.value").inner_html

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

to_twitter = []
to_twitter << pollen_value
to_twitter << pollen_type unless pollen_type.nil?
to_twitter << "(" + Time.now.gmtime.strftime("%a %d/%m") + ')'

if pollen_value
  begin
    Twitter.update(to_twitter.join(' '))
    # puts to_twitter.join(' ')
  rescue Exception => e
    puts "FAILED!"
    puts e.backtrace
    exit 1
  end
end

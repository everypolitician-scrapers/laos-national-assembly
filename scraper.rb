#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'pry'
require 'require_all'
require_rel 'lib'

# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped_page_archive/open-uri'

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

START = 'http://na.gov.la/index.php?option=com_content&view=category&id=28&Itemid=223&lang=en'

ConstituenciesPage.new(noko_for(START)).constituencies.each do |c|
  cp = ConstituencyPage.new(noko_for(URI.join(START, c[:url])))
  cp.members.each do |mem|
    data = mem.to_h.merge(cp.to_h).merge(term: 2016)
    ScraperWiki.save_sqlite([:name, :term], data)
  end
end

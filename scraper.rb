#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
require 'set'
# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped_page_archive/open-uri'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.css('.contentpane table tr a/@href').each do |href|
    link = URI.join url, href
    scrape_area(link)
  end
end

@prefixes = %w(Assoc Prof Dr Lt Col Colonel Mr Ms Dr Police Brigadier General).to_set
def remove_prefixes(name)
  enum = name.split(/\s/).slice_before { |w| !@prefixes.include? w.chomp('.') }
  [enum.take(1), enum.drop(1)].map { |l| l.join ' ' }
end

def scrape_area(url)
  noko = noko_for(url)
  noko.xpath('//div[@class="article-content"]//p//text()').each do |row|
    row_text = row.text.gsub('.',' ').gsub(/\d*/,'').gsub(/([A-Z])/,' \1')
    pref, name = remove_prefixes(row_text.tidy.sub('Col.X','Col X'))

    data = { 
      name: name,
      honorific_prefix: pref,
      area_id: area_id_and_name(noko)[0],
      area: area_id_and_name(noko)[1],
      term: 2016,
    }
    ScraperWiki.save_sqlite([:name, :term], data)
   end
end

def area_id_and_name(noko)
  noko.css('h2.contentheading')
      .text
      .tidy
      .match(/Constituency (\d+), (.*)/)
      .captures
end

scrape_list('http://na.gov.la/index.php?option=com_content&view=category&id=28&Itemid=223&lang=en')

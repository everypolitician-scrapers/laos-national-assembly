#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
require 'set'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

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

@prefixes = %w(Assoc Prof Dr Lt Col Colonel Mr Ms Dr).to_set
def remove_prefixes(name)
  enum = name.split(/\s/).slice_before { |w| !@prefixes.include? w.chomp('.') }
  [enum.take(1), enum.drop(1)].map { |l| l.join ' ' }
end

def scrape_area(url)
  noko = noko_for(url)
  area_id, area = noko.css('h2').text.tidy.match(/Constituency (\d+), (.*)/).captures
  noko.css('.article-content tr').each do |tr|
    tds = tr.css('td') 
    next unless tds[0] && tds[0].text.match(/\d/)
    pref, name = remove_prefixes(tds[1].text.tidy.sub('Col.X','Col X'))

    data = { 
      name: name,
      honorific_prefix: pref,
      area_id: area_id,
      area: area,
      term: 2011,
    }
    ScraperWiki.save_sqlite([:name, :term], data)
   end
end

scrape_list('http://na.gov.la/index.php?option=com_content&view=category&id=28&Itemid=223&lang=en')

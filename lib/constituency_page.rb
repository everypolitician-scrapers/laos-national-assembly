# frozen_string_literal: true
require_relative 'nokogiri_document'
require_relative 'member_row'

class ConstituencyPage < NokogiriDocument
  def members
    noko.xpath('//div[@class="article-content"]//p//text()').map do |row|
      MemberRow.new(row)
    end
  end

  field :area_id do
    area_data.first
  end

  field :area do
    area_data.last
  end

  private

  def area_data
    noko.css('h2.contentheading')
        .text
        .tidy
        .match(/Constituency (\d+), (.*)/)
        .captures
  end
end

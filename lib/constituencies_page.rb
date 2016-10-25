# frozen_string_literal: true
require_relative 'nokogiri_document'

class ConstituenciesPage < NokogiriDocument
  field :constituencies do
    noko.css('.contentpane table tr a').map do |a|
      {
        name: a.text.tidy,
        url:  a.attr('href'),
      }
    end
  end
end

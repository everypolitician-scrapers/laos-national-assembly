# frozen_string_literal: true
require 'field_serializer'
require 'nokogiri'

class String
  def tidy
    gsub(/[[:space:]]+/, ' ').strip
  end
end

class NokogiriDocument
  include FieldSerializer

  def initialize(noko)
    @noko = noko
  end

  private

  attr_reader :noko
end

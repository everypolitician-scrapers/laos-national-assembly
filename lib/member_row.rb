# frozen_string_literal: true
require_relative 'nokogiri_document'

class MemberRow < NokogiriDocument
  field :name do
    name_with_prefixes.last.split(' ').map(&:capitalize).join(' ')
  end

  field :honorific_prefix do
    name_with_prefixes.first
  end

  private

  def row_text
    @row_text ||= noko.text.delete('.').gsub(/\d*/, '')
                      .gsub(/([a-z](?=[A-Z]))/, '\1 ')
                      .tidy
  end

  def prefixes
    %w(Assoc Prof Dr Lt Col
       Colonel Mr Ms Dr Police Brigadier General).to_set
  end

  def name_with_prefixes
    enum = row_text.split(/\s/)
                   .slice_before { |w| !prefixes.include? w.chomp('.') }
    [enum.take(1), enum.drop(1)].map { |l| l.join ' ' }
  end
end

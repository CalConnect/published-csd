#!/usr/bin/env ruby

require 'nokogiri'
require 'relaton_calconnect'

class XMLOldParcer < RelatonCalconnect::XMLParser
  class << self
    private

    def item_data(cctitem)
      data = super
      data[:editorialgroup] ||= fetch_editorialgroup(cctitem)
      data
    end
  end
end

puts 'Start converting!'
puts

ARGV.each do |file_mask|
  Dir[file_mask].each do |file_path|
    file = File.read file_path
    puts file_path
    xml = Nokogiri::XML file
    bib = xml.at 'bibdata', 'bibitem'
    bib.xpath('xmlns:docidentifier').each do |di|
      if di[:type] == 'csd' then di[:type] = 'CC'
      else puts "Type is: #{di[:type]}"
      end
    end
    bib_xml = bib.to_xml
    item = XMLOldParcer.from_xml bib_xml
    new_bib_xml = item.to_xml bibdata: true
    bib.replace new_bib_xml
    File.write file_path, xml.to_xml
  end
end

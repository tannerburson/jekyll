require 'rubygems'
require 'fileutils'
require 'nokogiri'
require 'uri'

module Jekyll
  module Blogger
    def self.process(filename)
      FileUtils.mkdir_p "_posts"
      feed = Nokogiri::XML.parse(File.open(filename)).css('feed').first
      feed.css('entry').each do |entry|
        if entry.children.css('category').first['term'] =~ /post/
          tags = []
          entry.children.css('category').each { |e|
	          tags << e['term'] unless e['scheme'] =~ /schemas/
          }
          title = entry.children.css('title').first.content
          slug = entry.children.css('title').first.content
          date = DateTime.parse(entry.children.css('published').first.content)
          name = "%02d-%02d-%02d-%s.html" % [date.year, date.month, date.day, title]
          data = {
            'layout' => 'post',
            'title' => title,
            'permalink' => URI.split(entry.children.css('link').last['href'].to_s)[5],
            'tags' => tags
          }.to_yaml
          content = entry.children.css('content').first.content
          File.open("_posts/#{name}","w") do |f|
            f.puts data
            f.puts "---"
            f.puts content
          end
        end
      end
    end
  end
end

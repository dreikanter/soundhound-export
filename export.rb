require 'json'
require 'pry'
require 'open-uri'
require 'nokogiri'
require 'csv'

SOURCE_PATH = './tweets/*.js'.freeze

def urls(path)
  Dir.glob(path).map do |file_name|
    data = JSON.parse(File.read(file_name).sub(/.*\n/, ''))
    data.map do |entity|
      begin
        entity['entities']['urls'].first['expanded_url']
      rescue
        puts 'Unparsed entity'
        puts entity
        puts
      end
    end
  end.flatten
end

CSV.open('export.csv', 'wt') do |csv|
  urls(SOURCE_PATH).each do |url|
    begin
      puts url
      html = Nokogiri::HTML(open(url).read)
      title = html.css('.PageHeader-topText-title:first').first.text.strip
      artist = html.css('.PageHeader-topText-subtitle-emphasis:first').first.text.strip
      csv << [artist, title]
      puts [artist, title].join(' - ')
    rescue => e
      puts "Error: #{e.to_s}"
    end

    puts
    sleep 1
  end
end

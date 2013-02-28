require 'active_support/core_ext/object/blank'
require 'csv'
require 'net/http'
require 'nokogiri'
require 'open-uri'
require 'pathname'

# symbol is a string. Stock symbol
def proshare_bonus(symbol)
  doc     = Nokogiri::HTML(open("http://proshareng.com/quote/#{symbol}"))
  i       = 3
  bonuses = []

  while(true)
    row = doc.css("div#ebonus div div:nth-child(#{i}) div")
    value = row[0].text

    break if value.blank?
    close = row[4].text.strip
    bonus, per = value.scan(/\d+/)
    bonuses << [close, bonus, per]
    i = i + 1
  end

  return  bonuses.sort.uniq
end

def write_bonus(symbol)
  bonus_dir       = Pathname(__FILE__).join("..","..","bonus")

  CSV.open(bonus_dir.join("#{symbol.downcase}.csv"), 'wb') do |csvw|
    csvw << ["Date", "Bonus", "Per"]

    proshare_bonus(symbol).each do |bonus|
      csvw << bonus
    end

    puts "wrote #{symbol}"
  end
end

def write_bonuses
  securities_csv  = Pathname(__FILE__).join("..","..",'securities.csv')
  csv_contents    = CSV.parse(open(securities_csv).read)
  csv_contents.shift

  csv_contents.each do |csv|
    symbol  = csv[0]
    write_bonus(symbol)
  end
end

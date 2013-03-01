require 'active_support/core_ext/object/blank'
require 'csv'
require 'net/http'
require 'nokogiri'
require 'open-uri'
require 'pathname'

# symbol is a string. Stock symbol
def proshare_dividend(symbol)
  doc     = Nokogiri::HTML(open("http://proshareng.com/quote/#{symbol}"))
  i       = 3
  dividends = []

  while(true)
    row = doc.css("div#ediv div div:nth-child(#{i}) div")
    value = row[0].text

    break if value.blank?
    closedate = row[4].text.strip
    dividend = value
    dividends << [closedate, dividend]
    i = i + 1
  end

  return  dividends.sort.uniq
end

def write_dividend(symbol)
  dividend_dir       = Pathname(__FILE__).join("..","..","dividend")

  CSV.open(dividend_dir.join("#{symbol.downcase}.csv"), 'wb') do |csvw|
    csvw << ["Close", "Dividend"]

    proshare_dividend(symbol).each do |dividend|
      csvw << dividend
    end

    puts "wrote #{symbol}"
  end
end

def write_dividends
  securities_csv  = Pathname(__FILE__).join("..","..",'securities.csv')
  csv_contents    = CSV.parse(open(securities_csv).read)
  csv_contents.shift

  csv_contents.each do |csv|
    symbol  = csv[0]
    write_dividend(symbol)
  end
end

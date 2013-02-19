require 'active_support/core_ext/object/blank'
require 'csv'
require 'net/http'
require 'nokogiri'
require 'open-uri'
require 'pathname'


PRICE_HISTORY_URL   = 'http://www.cscsnigeriaplc.com/web/guest/pricelisthistory?p_p_id=SymbolPriceHistory_WAR_symbolpricehistoryportlet_INSTANCE_SsHb&p_p_lifecycle=1&p_p_state=normal&p_p_mode=view&p_p_col_id=column-2&p_p_col_count=1'
SECURITIES_LIST_URL = "http://94.236.31.41/web/guest/pricehistory"
SECURITIES_CSV      = Pathname(__FILE__).join("..","..",'securities.csv')

# Creates a list of all securities whose data is available at the CSCS site
# and writes the list to a CSV file
def securities
  doc =   Nokogiri::HTML(open(SECURITIES_LIST_URL))

  CSV.open(SECURITIES_CSV, 'wb') do |csv|
    csv << ["Symbol", "Name"]

    doc.css('option').each do |node|
      symbol  = node['value']
      name    = node.content.strip

      next if name.blank?
      csv << [symbol, name]
    end
  end

  puts "wrote securites list to #{SECURITIES_CSV}"
end

# Fetches historical price data for a single security. Case insensitive.
def price_history(symbol)
  uri           = URI(PRICE_HISTORY_URL)
  res           = Net::HTTP.post_form(uri, 'Symbol' => symbol)
  html_history  = Pathname(__FILE__).join("..", "..", "raw", "#{symbol}-pricehistory.html")
  csv_history   = Pathname(__FILE__).join("..", "..", "price", "#{symbol.downcase}.csv")

  File.open(html_history, 'w') do |f|
    f.write res.body
  end
  
  first_line = true

  CSV.open(csv_history, 'wb') do |csv|
    doc = Nokogiri::HTML(open(html_history))

    doc.css('.displayTable tr').each do |tr|
      if first_line
        first_line = false
        next
      end

      tds = tr.css('td').map(&:text)
      csv << tds
    end

    csv << ["Date", "Close", "Open"]
  end

  temp_file = Pathname(__FILE__).join("..","..","raw","rev")
  `tac #{csv_history} > #{temp_file} && cat #{temp_file} > #{csv_history}`
  throw `could not reverse file` unless $? == 0
  puts "wrote #{symbol} prices to #{csv_history}"
end

# Fetches price history for all securities available at CSCS site
def self.all_price_histories
  securities

  csv_contents = CSV.read(SECURITIES_CSV)
  csv_contents.shift
  csv_contents.each do |row|
    symbol = row[0]
    price_history(symbol)
  end
end

all_price_histories

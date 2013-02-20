require 'csv'
require 'open-uri'
require 'pathname'

DAILY_PRICE_URL = "http://www.cscsnigeriaplc.com/web/guest/dailypricelist?p_p_id=dailypricelist_WAR_dailypricelistportlet_INSTANCE_zHYy&p_p_lifecycle=2&p_p_cacheability=cacheLevelPage&p_p_col_id=column-2&p_p_col_count=1"
PRICE_DIR       = Pathname(__FILE__).join("..","..","price")

# file:String
#   path to a file
# date:String
#   date to search for in first column
def date_in_file?(file, date)
  CSV.foreach(file, "rb") do |row|
    next unless row[0] == date
    return true
  end

  return false
end

# Updates a history file with values for a date
# path: String
#   path to the history file
# symbol: String
#   symbol of the security. case insensitive
# date: String
#   The datestamp of the update values
# args: [String]
#   Update values
def update(path, symbol, date, *args)
  unless path.exist?
    puts "#{path} doesn't exist"
    return
  end

  if date_in_file?(path, date)
    puts "#{symbol}: #{date} already in file"
    return
  end

  CSV.open(path, "ab+") do |csv|
    csv << [date] + args
  end

  puts "#{symbol}: Updated"
end

# Fetches daily prcelist from CSCS site and updates price history files on disk
def update_all_prices
  csv_contents = CSV.parse(open(DAILY_PRICE_URL).read)
  csv_contents.shift
  csv_contents.each do |row|
    date        = Date.parse(row[0]).to_s
    symbol      = row[1]
    openprice   = row[3]
    closeprice  = row[4]
    price_path  = PRICE_DIR.join("#{symbol.downcase}.csv")
    
    update(price_path, symbol, date, closeprice, openprice)
  end
end

update_all_prices

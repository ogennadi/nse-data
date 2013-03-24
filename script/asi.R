library(XML)
library(xts)

date.format <- "%d/%m/%Y"

readASIFile <- function(file){
  df <-  readHTMLTable(file, header=FALSE, skip.rows=c(1, 2), which=2,
                        colClasses=c("character", "numeric", "numeric"))
  df[[1]]       <- as.Date(df[[1]], date.format)
  colnames(df)  <- c("Date", "Index", "Capitalisation")
  df
}

dataFrameToXTS <- function(df){
  as.xts(df[2:3], order.by=df$Date)
}

sortByDateDescending <- function(df){
  df[order(df$Date, decreasing=FALSE), ]
}

# The following functions must be run in the /script directory
ASI_FILE <- file.path("..", "asi.csv")

# Returns an XTS object containing previously downloaded ASI data
asi <- function(){
  df <- read.csv(ASI_FILE)
  as.xts(df[2:3], order.by=as.Date(df$Date))
}

# Go to cashcraft.com/indexmovement.asp, select the dates you want, download the resultant web page (as complete Web Page), then pass file as the argument to this function
writeASIDataFrame <- function(file){
  df <- sortByDateDescending(readASIFile(file))
  write.csv(df, file=ASI_FILE, row.names=FALSE)
}

# This script scrapes the Meristem site for All Share Index data. The data is
# split over a number of pages.
library(XML)
library(xts)

# V is a string representing a naira amount
parse.num <- function(v){
  as.numeric(gsub(',', '', sub("N ", "", v)))
}

# FNAME is a filename or URL
readhtml <- function(fname){
  t       <-readHTMLTable(fname, which=7, header=FALSE,
                          colClasses=c("character", "FormattedNumber", 
                                        "FormattedNumber", "FormattedNumber", 
                                        "character", "character"))
  t       <- na.omit(t)
  t[[5]]  <- parse.num(t[[5]])
  t[[6]]  <- parse.num(t[[6]])
  colnames(t) <- c("Date","NSE Index","Deals", "Traded Volume", "Traded Value",
                    "Market Capitalization")
  t
}

# Y1, M1, D1 are the start date
# Y2, M2, D2 are the end date
# Experiments show the data only starts from April 2008
fetchASI <- function(y1, m1, d1, y2, m2, d2, startpage=0){
  tdir <- tempdir()
  print(tdir)
  index   <- startpage
  ret   <- data.frame()
  
  repeat{
    print(index)
    tempfile  <- file.path(tdir, paste0(index, ".html"))
    currurl   <- paste0("http://www.meristem.com.ng/marketserve/stkmktsummaryhistory.php?pageNum_rsPrice=", index, "&mm=", m1,"&dd=", d1,"&YYYY=", y1,"&mm2=", m2,"&dd2=", d2,"&YYYY2=", y2,"&submit=GET+ALL")
    download.file(currurl, tempfile)
    currframe <- readhtml(tempfile)

    if(nrow(currframe) == 0){
      break
    }

    ret   <- rbind(ret, currframe)
    ret   <- ret[order(ret[1], decreasing=TRUE), ]
    index <- index + 1
  }

  ret
}

# In case the download stops halfway
# DIR is a directory containing the downloaded HTML pages
dirToDataFrame <- function(dir){
  files <- list.files(dir, full.names=TRUE)
  ret   <- data.frame()

  for(file in files){
    currframe <- readhtml(file)
    ret       <- rbind(ret, currframe)
    print(nrow(currframe))
  }

  ret   <- ret[order(ret[1], decreasing=TRUE), ]
  ret
}

# The following functions must be run in the /script directory
ASI_FILE <- file.path("..", "asi.csv")

# Returns an XTS object containing previously downloaded ASI data
asi <- function(){
  df <- read.csv(ASI_FILE)
  as.xts(df[2:6], order.by=as.Date(df$Date))
}

# Fetches ASI data from the Web and writes it to ASI_FILE
writeASI <- function(y1, m1, d1, y2, m2, d2, startpage=0){
  df <- fetchASI(y1, m1, d1, y2, m2, d2, startpage)
  write.csv(df, file=ASI_FILE, row.names=FALSE)
}

# Concatenates ASI data from a directory into ASI_FILE
writeASIDir <- function(dir){
  df <- dirToDataFrame(dir)
  write.csv(df, file=ASI_FILE, row.names=FALSE)
}

# Removes all rows in a file whose date is duplicated
# path: String
#   path to the file
remove.duplicate <- function(path){
  df      = read.csv(path, as.is=TRUE)
  unique  = df[!duplicated(df[1]),]
  write.csv(unique, file=path, row.names=FALSE, quote=FALSE)
}

args <- commandArgs(trailingOnly = TRUE)
sapply(args, remove.duplicate)

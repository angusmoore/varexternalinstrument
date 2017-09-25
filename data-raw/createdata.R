GKdata <- read.csv("GKdata.csv", header = TRUE)
# zero out the 1990 year of data because GK use 1991 onwards as their sample
GKdata[127:138,"ff4_tc"] <- NA
devtools::use_data(GKdata, overwrite = TRUE)

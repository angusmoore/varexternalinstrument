GKdata <- read.csv("GKdata.csv", header = TRUE)

devtools::use_data(GKdata, overwrite = TRUE)

library(vars)

data(GKdata)

gkvar <- VAR(GKdata[, c("logip", "logcpi", "gs1", "ebp")], p = 12, type = "const")
shockcol <- externalinstrument(gkvar, GKdata$ff4_tc, "gs1")

shouldbe <- c(0.04577746, -0.03861414, 0.21901224, 0.11187556)
test_that(shockcol, equals(shouldbe))

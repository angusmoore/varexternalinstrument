library(vars)

data(GKdata)

test_that("Replicate GK", {
    gkvar <- VAR(GKdata[, c("logip", "logcpi", "gs1", "ebp")], p = 12, type = "const")
    shockcol <- externalinstrument(gkvar, GKdata$ff4_tc, "gs1")

    shouldbe <- c(0.02886238, -0.03275585, 0.19549144, 0.11296773 )
    expect_equal(unname(shockcol), unname(shouldbe))
})

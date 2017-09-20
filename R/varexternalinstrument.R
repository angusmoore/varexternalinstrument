externalinstrument <- function(x, ...)
  UseMethod("externalinstrument")

#' Identify the impulse response for a VAR (using the VAR estimated from the vars package), using a high frequency instrument.
#'
#' @param var A varest object (resulting from a var estimation from the vars package).
#' @param instrument A list containing the data for the instrument. Should be same length as the estimation sample.
#' @param dependent Which variable in your var are you instrumenting (as a string).
#'
#' @examples
#' library(vars)
#' T <- 24
#' randomdata <- (data.frame(x1 = rnorm(T), x2 = rnorm(T), x3 = rnorm(T, sd = 10)))
#' myvar <- VAR(randomdata[, c("x1","x2")], p = 1)
#' HFI(myvar, randomdata$x3, "x1")
#'
#' @export
externalinstrument.varest <- function(var, instrument, dependent) {
  res <- data.frame(stats::residuals(var))
  p <- var$p
  return(externalinstrument(res, instrument[(p+1):length(instrument)], dependent, p))
}

#' Identify the impulse response for a VAR (using the residuals from the VAR), using a high frequency instrument.
#'
#' @param res A data frame containing the reduced form residuals from your vAR.
#' @param instrument A list containing the data for the instrument. Should be same length as the data frame of residuals.
#' @param dependent Which variable in your var are you instrumenting (as a string).
#' @param p (Integer) How many lags does your var have.
#'
#' @export
externalinstrument.data.frame <- function(res, instrument, dependent, p) {
  seriesnames <- colnames(res)
  origorder <- seriesnames
  if (dependent %in% seriesnames) {
    # order dependent first
    seriesnames <- seriesnames[seriesnames != dependent]
    seriesnames <- c(dependent, seriesnames) # Order the dependent variable first
  } else {
    stop(paste("The series you are trying to instrument (", dependent, ") is not a series in the residual dataframe.", sep =""))
  }
  # Merge the instrument into the data frame
  res[, "instrument"] <- instrument

  # put together matrix of residuals
  u <- as.matrix(res[, seriesnames])

  # Now restrict to just the sample for the instrument (if necessary)
  u <- u[!is.na(res[, "instrument"]), ]

  # Useful constants
  T <- nrow(u)
  k <- ncol(u)

  # Some necessary parts of the covariance matrix
  gamma <- (1 / (T - k*p - 1)) * t(u) %*% u
  gamma_11 <- gamma[1,1]
  gamma_21 <- matrix(gamma[2:nrow(gamma), 1], c(k-1,1))
  gamma_22 <- matrix(gamma[2:nrow(gamma), 2:nrow(gamma)], c(k-1,k-1))

  # First stage regression
  firststage <- stats::lm(stats::as.formula(paste(dependent, " ~ instrument", sep = "")), res)
  res[names(stats::predict(firststage)), "fs"] <- stats::predict(firststage)

  # Now get the second-stage coefficients - this becomes the column (though we need to scale it)
  coefs <- rep(0, k)
  names(coefs) <- seriesnames
  for (i in 1:k) {
    s <- seriesnames[i]
    if (s != dependent) {
      secondstage <- stats::lm(stats::as.formula(paste(s, " ~ fs", sep = "")), res)
      coefs[i] <- secondstage$coefficients["fs"]
    } else {
      coefs[i] <- firststage$coefficients["instrument"]
    }
  }
  s21_on_s11 <- matrix(coefs[2:k], c(k-1,1))

  Q <- (s21_on_s11 * gamma_11) %*% t(s21_on_s11) - (gamma_21 %*% t(s21_on_s11) + s21_on_s11 %*% t(gamma_21)) + gamma_22

  s12s12 <- t(gamma_21 - s21_on_s11 * gamma_11) %*% solve(Q) %*% (gamma_21 - s21_on_s11 * gamma_11)

  s11_squared <- gamma_11 - s12s12

  sp <- as.numeric(sqrt(s11_squared))

  # finally, scale the coefs (the colnames are used to reorder to the original ordering)
 return(sp * coefs[origorder])
}

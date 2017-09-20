[![Travis-CI Build Status](https://travis-ci.org/angusmoore/varHFinstrument.svg?branch=master)](https://travis-ci.org/angusmoore/varHFinstrument)
[![Coverage Status](https://coveralls.io/repos/github/angusmoore/varexternalinstruments/badge.svg?branch=master)](https://coveralls.io/github/angusmoore/varexternalinstrument?branch=master)

# varexternalinstrument
`varexternalinstrument` is an R library that implements the external instruments identification method from Gertler Karadi (2015), Stock and Watson (2012) and Mertens and Ravn (2013) for the R vars package.

## Installation

Install the package using the R `devtools` package:
```
library(devtools)
install_github("angusmoore/varexternalinstrument")
```

## Usage
The library is designed to work with the R `vars` package, though an interface is available to work with a generic set of reduced form residuals.

The package includes the replication data from Gertler Karadi (the original data can be found here: https://www.aeaweb.org/aej/mac/data/0701/2013-0329_data.zip. 

The library integrates easily with the `vars` package. The following example illustrates how to replicate the main result from Gertler and Karadi (2015).

```
library(vars)
library(varexternalinstrument)

data(GKdata)

gkvar <- VAR(GKdata[, c("logip", "logcpi", "gs1", "ebp")], p = 12, type = "const")
shockcol <- externalinstrument(gkvar, GKdata$ff4_tc, "gs1")
```

The result, `shockcol` contains the instaneous response of each of the variables in the VAR to a shock to `gs1` (in this case, the monetary policy indicator). This can then be used to create IRFs, etc.

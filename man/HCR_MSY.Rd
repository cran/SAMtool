% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/HCRs.R
\name{HCR_MSY}
\alias{HCR_MSY}
\title{Harvest control rule to fish at some fraction of maximum sustainable yield}
\usage{
HCR_MSY(Assessment, reps = 1, MSY_frac = 1, ...)
}
\arguments{
\item{Assessment}{An object of class \linkS4class{Assessment} with estimates of
FMSY or UMSY and vulnerable biomass in terminal year.}

\item{reps}{The number of stochastic samples of the TAC recommendation.}

\item{MSY_frac}{The fraction of FMSY or UMSY for calculating the TAC (e.g. MSY_frac = 0.75 fishes at 75\% of FMSY).}

\item{...}{Miscellaneous arguments.}
}
\value{
An object of class \link[MSEtool:Rec-class]{MSEtool::Rec} with the TAC recommendation.
}
\description{
A simple control rule that specifies the total allowable catch (TAC) as a function of the abundance of the first
projection year and some fraction of FMSY/UMSY.
}
\details{
The catch advice is calculated using the catch equation of the corresponding
assessment. See \code{Assessment@forecast$catch_eq}, a function that returns the catch advice for a specified \code{Ftarget}.
}
\examples{
# create an MP to run in closed-loop MSE (fishes at UMSY)
SPMSY <- make_MP(SP, HCR_MSY)

# The MP which fishes at 75\% of FMSY
SP75MSY <- make_MP(SP, HCR_MSY, MSY_frac = 0.75)

\donttest{
myOM <- MSEtool::runMSE(MSEtool::testOM, MPs = c("FMSYref", "SPMSY", "SP75MSY"))
}
}
\references{
Punt, A. E, Dorn, M. W., and Haltuch, M. A. 2008. Evaluation of threshold management strategies
for groundfish off the U.S. West Coast. Fisheries Research 94:251-266.
}
\seealso{
\link{make_MP} \link{HCR_ramp}
}
\author{
Q. Huynh
}

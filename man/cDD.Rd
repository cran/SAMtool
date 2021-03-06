% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/assess_cDD.R
\name{cDD}
\alias{cDD}
\alias{cDD_SS}
\title{Continuous Delay-differential assessment model}
\usage{
cDD(
  x = 1,
  Data,
  AddInd = "B",
  SR = c("BH", "Ricker"),
  rescale = "mean1",
  MW = FALSE,
  start = NULL,
  prior = list(),
  fix_h = TRUE,
  dep = 1,
  LWT = list(),
  n_itF = 5L,
  silent = TRUE,
  opt_hess = FALSE,
  n_restart = ifelse(opt_hess, 0, 1),
  control = list(iter.max = 5000, eval.max = 10000),
  ...
)

cDD_SS(
  x = 1,
  Data,
  AddInd = "B",
  SR = c("BH", "Ricker"),
  rescale = "mean1",
  MW = FALSE,
  start = NULL,
  prior = list(),
  fix_h = TRUE,
  fix_sigma = FALSE,
  fix_tau = TRUE,
  dep = 1,
  LWT = list(),
  n_itF = 5L,
  integrate = FALSE,
  silent = TRUE,
  opt_hess = FALSE,
  n_restart = ifelse(opt_hess, 0, 1),
  control = list(iter.max = 5000, eval.max = 10000),
  inner.control = list(),
  ...
)
}
\arguments{
\item{x}{An index for the objects in \code{Data} when running in closed loop simulation.
Otherwise, equals to 1 when running an assessment.}

\item{Data}{An object of class \linkS4class{Data}.}

\item{AddInd}{A vector of integers or character strings indicating the indices to be used in the model. Integers assign the index to
the corresponding index in Data@AddInd, "B" (or 0) represents total biomass in Data@Ind, "VB" represents vulnerable biomass in
Data@VInd, and "SSB" represents spawning stock biomass in Data@SpInd.}

\item{SR}{Stock-recruit function (either \code{"BH"} for Beverton-Holt or \code{"Ricker"}).}

\item{rescale}{A multiplicative factor that rescales the catch in the assessment model, which
can improve convergence. By default, \code{"mean1"} scales the catch so that time series mean is 1, otherwise a numeric.
Output is re-converted back to original units.}

\item{MW}{Logical, whether to fit to mean weight. In closed-loop simulation, mean weight will be grabbed from \code{Data@Misc[[x]]$MW},
otherwise calculated from \code{Data@CAL}.}

\item{start}{Optional list of starting values. Entries can be expressions that are evaluated in the function. See details.}

\item{prior}{A named list (R0, h, M, and q) to provide the mean and standard deviations of prior distributions for those parameters. R0, index q, and M priors are
lognormal (provide the mean in normal space, SD in lognormal space). Beverton-Holt steepness uses a beta prior, while Ricker steepness uses a normal prior.
For index q, provide a matrix for nsurvey rows and 2 columns (for mean and SD), with NA in rows corresponding to indices without priors. For all others, provide a length-2 vector for the mean and SD.
See vignette for full description.}

\item{fix_h}{Logical, whether to fix steepness to value in \code{Data@steep} in the assessment model.}

\item{dep}{The initial depletion in the first year of the model. A tight prior is placed on the model objective function
to estimate the equilibrium fishing mortality corresponding to the initial depletion. Due to this tight prior, this F
should not be considered to be an independent model parameter. Set to zero to eliminate this prior.}

\item{LWT}{A named list of likelihood weights. For \code{LWT$Index}, a vector of likelihood weights for each survey, while
for \code{LWT$MW} a numeric.}

\item{n_itF}{Integer, the number of iterations to solve F conditional on the observed catch.}

\item{silent}{Logical, passed to \code{\link[TMB]{MakeADFun}}, whether TMB
will print trace information during optimization. Used for diagnostics for model convergence.}

\item{opt_hess}{Logical, whether the hessian function will be passed to \code{\link[stats]{nlminb}} during optimization
(this generally reduces the number of iterations to convergence, but is memory and time intensive and does not guarantee an increase
in convergence rate). Ignored if \code{integrate = TRUE}.}

\item{n_restart}{The number of restarts (calls to \code{\link[stats]{nlminb}}) in the optimization procedure, so long as the model
hasn't converged. The optimization continues from the parameters from the previous (re)start.}

\item{control}{A named list of parameters regarding optimization to be passed to
\code{\link[stats]{nlminb}}.}

\item{...}{Additional arguments (not currently used).}

\item{fix_sigma}{Logical, whether the standard deviation of the index is fixed. If \code{TRUE},
sigma is fixed to value provided in \code{start} (if provided), otherwise, value based on \code{Data@CV_Ind}.}

\item{fix_tau}{Logical, the standard deviation of the recruitment deviations is fixed. If \code{TRUE},
tau is fixed to value provided in \code{start} (if provided), otherwise, equal to 1.}

\item{integrate}{Logical, whether the likelihood of the model integrates over the likelihood
of the recruitment deviations (thus, treating it as a state-space variable). Otherwise, recruitment deviations are penalized parameters.}

\item{inner.control}{A named list of arguments for optimization of the random effects, which
is passed on to \code{\link[TMB]{newton}} via \code{\link[TMB]{MakeADFun}}.}
}
\value{
An object of \code{\linkS4class{Assessment}} containing objects and output
from TMB.
}
\description{
A catch and index-based assessment model. Compared to the discrete delay-difference (annual time-step in production and fishing), the
delay-differential model (cDD) is based on continuous recruitment and fishing mortality within a time-step. The continuous model works
much better for populations with high turnover (e.g. high F or M, continuous reproduction). This model is conditioned on catch and fits
to the observed index. In the state-space version (cDD_SS), recruitment deviations from the stock-recruit relationship are estimated.
}
\details{
For \code{start} (optional), a named list of starting values of estimates can be provided for:
\itemize{
\item \code{R0} Unfished recruitment. Otherwise, Data@OM$R0[x] is used in closed-loop, and 400\% of mean catch otherwise.
\item \code{h} Steepness. Otherwise, Data@steep[x] is used, or 0.9 if empty.
\item \code{Kappa} Delay-differential Kappa parameter. Otherwise, calculated from biological parameters in the Data object.
\item \code{F_equilibrium} Equilibrium fishing mortality leading into first year of the model (to determine initial depletion). By default, 0.
\item \code{tau} Lognormal SD of the recruitment deviations (process error) for \code{DD_SS}. By default, Data@sigmaR[x].
\item \code{sigma} Lognormal SD of the index (observation error). By default, Data@CV_Ind[x]. Not
used if multiple indices are used.
\item \code{sigma_W} Lognormal SD of the mean weight (observation error). By default, 0.1.
}

Multiple indices are supported in the model. Data@Ind, Data@VInd, and Data@SpInd are all assumed to be biomass-based.
For Data@AddInd, Data@I_units are used to identify a biomass vs. abundance-based index.
}
\section{Online Documentation}{

Model description and equations are available on the openMSE 
\href{https://openmse.com/features-assessment-models/1-dd/}{website}.
}

\section{Required Data}{

\itemize{
\item \code{cDD}: Cat, Ind, Mort, L50, vbK, vbLinf, vbt0, wla, wlb, MaxAge
\item \code{cDD_SS}: Cat, Ind, Mort, L50, vbK, vbLinf, vbt0, wla, wlb, MaxAge
}
}

\section{Optional Data}{

\itemize{
\item \code{cDD}: steep
\item \code{cDD_SS}: steep, CV_Ind, sigmaR
}
}

\examples{
#### Observation-error delay difference model
res <- cDD(Data = MSEtool::Red_snapper)

### State-space version
### Also set recruitment variability SD = 0.6 (since fix_tau = TRUE)
res <- cDD_SS(Data = MSEtool::Red_snapper, start = list(tau = 0.6))

summary(res@SD) # Parameter estimates
}
\references{
Hilborn, R., and Walters, C., 1992. Quantitative Fisheries Stock Assessment: Choice,
Dynamics and Uncertainty. Chapman and Hall, New York.
}
\seealso{
\link{DD_TMB} \link{plot.Assessment} \link{summary.Assessment} \link{retrospective} \link{profile} \link{make_MP}
}
\author{
Q. Huynh
}

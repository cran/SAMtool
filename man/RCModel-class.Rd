% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/define_S4_class_RCModel.R
\docType{class}
\name{RCModel-class}
\alias{RCModel-class}
\alias{RCModel}
\title{Class-\code{RCModel}}
\description{
An S4 class for the output from \link{RCM}.
}
\section{Slots}{

\describe{
\item{\code{OM}}{An updated operating model, class \link[MSEtool:OM-class]{MSEtool::OM}.}

\item{\code{SSB}}{A matrix of estimated spawning biomass with \code{OM@nsim} rows and \code{OM@nyears+1} columns.}

\item{\code{NAA}}{An array for the predicted numbers at age with dimension \code{OM@nsim}, \code{OM@nyears+1}, and \code{OM@maxage+1}.}

\item{\code{CAA}}{An array for the predicted catch at age with dimension \code{OM@nsim}, \code{OM@nyears}, \code{OM@maxage}, and nfleet.}

\item{\code{CAL}}{An array for the predicted catch at length with dimension \code{OM@nsim}, \code{OM@nyears}, length bins, and nfleet.}

\item{\code{conv}}{A logical vector of length \code{OM@nsim} indicating convergence of the RCM in the i-th simulation.}

\item{\code{report}}{A list of length \code{OM@nsim} with more output from the fitted RCM. Within each simulation, a named list containing items of interest include:

\itemize{
\item B - total biomass - vector of length nyears+1
\item EPR0 - annual unfished spawners per recruit - vector of length nyears
\item ageM - age of 50\% maturity - integer
\item EPR0_SR - unfished spawners per recruit for the stock-recruit relationship (mean EPR0 over the first \code{ageM} years) - numeric
\item R0 - unfished recruitment for the stock-recruit relationship - numeric
\item h - steepness for the stock-recruit relationship - numeric
\item Arec - stock-recruit alpha parameter - numeric
\item Brec - stock-recruit beta parameter - numeric
\item E0_SR - unfished spawning biomass for the stock-recruit relationship (product of EPR0_SR and R0) - numeric
\item CR_SR - compensation ratio, the product of Arec and EPR0_SR - numeric
\item E0 - annual unfished spawning biomass (intersection of stock-recruit relationship and unfished spawners per recruit) - vector of length nyears
\item R0_annual - annual unfished recruitment (annual ratio of E0 and EPR0) - vector of length nyears
\item h_annual - annual steepness (calculated from EPR0 and Arec) - vector of length nyears
\item CR - annual compensation ratio, the product of alpha and annual unfished spawners per recruit (EPR0) - vector of length nyears
\item R - recruitment - vector of length nyears+1
\item R_early - recruitment for the cohorts in first year of the model - vector n_age-1 (where n_age = maxage + 1)
\item VB - vulnerable biomass - matrix of nyears x nfleet
\item N - abundance at age - matrix of nyears+1 x n_age
\item F - apical fishing mortality - matrix of nyears x nfleet
\item F_at_age - fishing mortality at age - matrix of nyears x n_age
\item F_equilibrium - equilibrium fishing mortality prior to first year - vector of length nfleet
\item M - natural mortality - matrix of nyears x n_age
\item Z - total mortality - matrix of nyears x n_age
\item q - index catchability - vector of length nsurvey
\item ivul - index selectivity at age - array of dim nyears+1, n_age, nsurvey
\item ivul_len - corresponding index selectivity at length - matrix of nbins x nsurvey
\item Ipred - predicted index values - matrix of nyears x nsurvey
\item IAApred - predicted index catch at age - array of dim nyears, n_age, nsurvey
\item vul - fleet selectivity at age - array of dim nyears+1, n_age, nfleet (or nsel_block)
\item vul_len - corresponding fleet selectivity at length - matrix of nbins x nfleet (or nsel_block)
\item IALpred - predicted index catch at length - array of dim nyears, nbins, nsurvey
\item MLpred - predicted mean length - matrix of nyears x nfleet
\item MWpred - predicted mean weight - matrix of nyears x nfleet
\item CAApred - predicted catch at age - array of nyears, n_age, nfleet
\item CALpred - predicted catch at length - array of nyears, nbins, nfleet
\item Cpred - predicted catch in weight - matrix of nyears x nfleet
\item CN - predicted catch in numbers - matrix of nyears x nfleet
\item dynamic_SSB0 - the dynamic unfished spawning biomass calcaluated by projecting the historical model with zero catches - vector of length nyears+1
\item SPR_eq - equilibrium spawning potential ratio calculated from annual F-at-age - vector of length nyears
\item SPR_dyn - dynamic (transitional) spawning potential ratio calculated from cumulative survival of cohorts - vector of length nyears
\item nll - total objective function of the model - numeric
\item nll_fleet - objective function values for each annual data point(s) from fleets - array of nyears x nfleet x 5 (for Catch, equilibrium catch, CAA, CAL, and mean size)
\item nll_index - objective function values for each annual data point(s) in the index - array of nyears x nsurvey x 3 (for Index, IAA, and IAL)
\item prior - penalty value added to the objective function from priors - numeric
\item penalty - additional penalty values added to the objective function due to high F - numeric
\item conv - whether the model converged (whether a positive-definite Hessian was obtained) - logical
}}

\item{\code{mean_fit}}{A list of output from fit to mean values of life history parameters in the operating model. The named list consists of:

\itemize{
\item obj - a list with components returned from \code{\link[TMB:MakeADFun]{TMB::MakeADFun()}}.
\item opt - a list with components from calling \code{\link[stats:nlminb]{stats::nlminb()}} to \code{obj}.
\item SD - a list (class sdreport) with parameter estimates and their standard errors, obtained from
\code{\link[TMB:sdreport]{TMB::sdreport()}}.
\item report - a list of model output reported from the TMB executable, i.e. \code{obj$report()}. See Misc.
}}

\item{\code{data}}{A \linkS4class{RCMdata} object containing data inputs for the RCM.}

\item{\code{config}}{A list describing configuration of the RCM:
\itemize{
\item drop_sim - a vector of simulations that were dropped for the output
}}

\item{\code{Misc}}{Slot for miscellaneous information for the user. Currently unused.}
}}

\seealso{
\link{plot.RCModel} \link{RCM}
}
\author{
Q. Huynh
}

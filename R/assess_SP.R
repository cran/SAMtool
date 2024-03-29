#' Surplus production model with FMSY and MSY as leading parameters
#'
#' A surplus production model that uses only a time-series of catches and a relative abundance index
#' and coded in TMB. The base model, `SP`, is conditioned on catch and estimates a predicted index.
#' Continuous surplus production and fishing is modeled with sub-annual time steps which should approximate
#' the behavior of ASPIC (Prager 1994). The Fox model, `SP_Fox`, fixes BMSY/K = 0.37 (1/e).
#' The state-space version, `SP_SS` estimates annual deviates in biomass. An option allows for setting a
#' prior for the intrinsic rate of increase.
#' The function for the `spict` model (Pedersen and Berg, 2016) is available in [MSEextra][MSEtool::MSEextra].
#'
#' @param x An index for the objects in `Data` when running in [runMSE][MSEtool::runMSE].
#' Otherwise, equals to 1 When running an assessment interactively.
#' @param Data An object of class Data.
#' @param AddInd A vector of integers or character strings indicating the indices to be used in the model. Integers assign the index to
#' the corresponding index in Data@@AddInd, "B" (or 0) represents total biomass in Data@@Ind, "VB" represents vulnerable biomass in
#' Data@@VInd, and "SSB" represents spawning stock biomass in Data@@SpInd.
#' @param rescale A multiplicative factor that rescales the catch in the assessment model, which
#' can improve convergence. By default, `"mean1"` scales the catch so that time series mean is 1, otherwise a numeric.
#' Output is re-converted back to original units.
#' @param start Optional list of starting values. Entries can be expressions that are evaluated in the function. See details.
#' @param prior A named list for the parameters of any priors to be added to the model. See details.
#' @param fix_dep Logical, whether to fix the initial depletion (ratio of biomass to carrying capacity in the
#' first year of the model). If `TRUE`, uses the value in `start`, otherwise equal to 1
#' (unfished conditions).
#' @param fix_n Logical, whether to fix the exponent of the production function. If `TRUE`,
#' uses the value in `start`, otherwise equal to `n = 2`, where the biomass at MSY
#' is half of carrying capacity.
#' @param fix_sigma Logical, whether the standard deviation of the index is fixed. If `TRUE`,
#' sigma is fixed to value provided in `start` (if provided), otherwise, value based on `Data@@CV_Ind`.
#' @param fix_tau Logical, the standard deviation of the biomass deviations is fixed. If `TRUE`,
#' tau is fixed to value provided in `start` (if provided), otherwise, equal to 0.1.
#' @param early_dev Character string describing the years for which biomass deviations are estimated in `SP_SS`.
#' By default, deviations are estimated in each year of the model (`"all"`), while deviations could also be estimated
#' once index data are available (`"index"`).
#' @param LWT A vector of likelihood weights for each survey.
#' @param n_seas Integer, the number of seasons in the model for calculating continuous surplus production.
#' @param n_itF Integer, the number of iterations to solve F conditional on the observed catch given multiple seasons within an annual time step.
#' Ignored if `n_seas` = 1.
#' @param integrate Logical, whether the likelihood of the model integrates over the likelihood
#' of the biomass deviations (thus, treating it as a state-space variable).
#' @param Euler_Lotka Integer. If greater than zero, the function will calculate a prior for the intrinsic rate of increase to use in the estimation model
#' (in lieu of an explicit prior in argument `prior`). The value of this argument specifies the number of stochastic samples used to calculate the prior SD. 
#' See section on priors below.
#' @param SR_type If `use_r_prior = TRUE`, the stock-recruit relationship used to calculate the stock-recruit alpha parameter from 
#' steepness and unfished spawners-per-recruit. Used to develop the r prior.
#' @param silent Logical, passed to [TMB::MakeADFun()], whether TMB
#' will print trace information during optimization. Used for diagnostics for model convergence.
#' @param opt_hess Logical, whether the hessian function will be passed to [stats::nlminb()] during optimization
#' (this generally reduces the number of iterations to convergence, but is memory and time intensive and does not guarantee an increase
#' in convergence rate). Ignored if `integrate = TRUE`.
#' @param n_restart The number of restarts (calls to [stats::nlminb()]) in the optimization procedure, so long as the model
#' hasn't converged. The optimization continues from the parameters from the previous (re)start.
#' @param control A named list of parameters regarding optimization to be passed to
#' [stats::nlminb()].
#' @param inner.control A named list of arguments for optimization of the random effects, which
#' is passed on to [newton][TMB::newton] via [TMB::MakeADFun()].
#' @param ... For `SP_Fox`, additional arguments to pass to `SP`.
#' @details
#' For `start` (optional), a named list of starting values of estimates can be provided for:
#' \itemize{
#' \item `MSY` Maximum sustainable yield.. Otherwise, 300% of mean catch by default.
#' \item `FMSY` Steepness. Otherwise, `Data@@Mort[x]` or 0.2 is used.
#' \item `dep` Initial depletion (B/B0) in the first year of the model. By default, 1.
#' \item `n` The production function exponent that determines BMSY/B0. By default, 2 so that BMSY/B0 = 0.5.
#' \item `sigma` Lognormal SD of the index (observation error). By default, 0.05. Not
#' used with multiple indices.
#' \item `tau` Lognormal SD of the biomass deviations (process error) in `SP_SS`. By default, 0.1.
#' }
#' 
#' Multiple indices are supported in the model. 
#' 
#' Tip: to create the Fox model (Fox 1970), just fix n = 1. See example.
#' @section Priors:
#' The following priors can be added as a named list, e.g., prior = list(r = c(0.25, 0.15), MSY = c(50, 0.1). For each parameter below, provide a vector of values as described:
#' 
#' \itemize{
#' \item `r` - A vector of length 2 for the lognormal prior mean (normal space) and SD (lognormal space). 
#' \item `MSY` - A vector of length 2 for the lognormal prior mean (normal space) and SD (lognormal space).
#' }
#' 
#' In lieu of an explicit r prior provided by the user, set argument `Euler_Lotka = TRUE` to calculate the prior mean and SD using
#' the Euler-Lotka method (Equation 15a of McAllister et al. 2001).
#' The Euler-Lotka method is modified to multiply the left-hand side of equation 15a by the alpha parameter of the
#' stock-recruit relationship (Stanley et al. 2009). Natural mortality and steepness are sampled in order to generate
#' a prior distribution for r. See `vignette("Surplus_production")` for more details.
#' @return An object of [Assessment-class] containing objects and output from TMB.
#' @note The model uses the Fletcher (1978) formulation and is parameterized with FMSY and MSY as
#' leading parameters. The default conditions assume unfished conditions in the first year of the time series
#' and a symmetric production function (n = 2).
#' 
#' @section Online Documentation:
#' Model description and equations are available on the openMSE 
#' [website](https://openmse.com/features-assessment-models/3-sp/).
#' 
#' @author Q. Huynh
#' @references
#' Fletcher, R. I. 1978. On the restructuring of the Pella-Tomlinson system. Fishery Bulletin 76:515:521.
#'
#' Fox, W.W. 1970. An exponential surplus-yield model for optimizing exploited fish populations. Transactions of the American Fisheries Society 99:80-88.
#'
#' McAllister, M.K., Pikitch, E.K., and Babcock, E.A. 2001. Using demographic methods to construct Bayesian priors
#' for the intrinsic rate of increase in the Schaefer model and implications for stock rebuilding. Can. J. Fish.
#' Aquat. Sci. 58: 1871-1890.
#'
#' Pedersen, M. W. and Berg, C. W. 2017. A stochastic surplus production model in continuous time. Fish and Fisheries. 18:226-243.
#'
#' Pella, J. J. and Tomlinson, P. K. 1969. A generalized stock production model. Inter-Am. Trop. Tuna Comm., Bull. 13:419-496.
#'
#' Prager, M. H. 1994. A suite of extensions to a nonequilibrium surplus-production model. Fishery Bulletin 92:374-389.
#'
#' Stanley, R.D., M. McAllister, P. Starr and N. Olsen. 2009. Stock assessment for bocaccio (Sebastes
#' paucispinis) in British Columbia waters. DFO Can. Sci. Advis. Sec. Res. Doc. 2009/055. xiv + 200 p.
#' @section Required Data:
#' \itemize{
#' \item `SP`: Cat, Ind
#' \item `SP_SS`: Cat, Ind
#' }
#' @section Optional Data:
#' `SP_SS`: CV_Ind
#' @examples
#' data(swordfish)
#'
#' #### Observation-error surplus production model
#' res <- SP(Data = swordfish)
#'
#' # Provide starting values, assume B/K = 0.875 in first year of model
#' # and symmetrical production curve (n = 2)
#' start <- list(dep = 0.875, n = 2)
#' res <- SP(Data = swordfish, start = start)
#'
#' \donttest{
#' plot(res)
#' profile(res, FMSY = seq(0.1, 0.4, 0.01))
#' retrospective(res)
#' }
#'
#' #### State-space version
#' res_SS <- SP_SS(Data = swordfish, start = list(dep = 0.875, sigma = 0.1, tau = 0.1))
#'
#' \donttest{
#' plot(res_SS)
#' }
#'
#' #### Fox model
#' res_Fox <- SP(Data = swordfish, start = list(n = 1), fix_n = TRUE)
#' res_Fox2 <- SP_Fox(Data = swordfish)
#'
#' #### SP with r prior calculated internally (100 stochastic samples to get prior SD)
#' res_prior <- SP(Data = SimulatedData, Euler_Lotka = 100)
#'
#' #### Pass an r prior to the model with mean = 0.35, lognormal sd = 0.10
#' res_prior2 <- SP(Data = SimulatedData, prior = list(r = c(0.35, 0.10)))
#' 
#' #### Pass MSY prior to the model with mean = 1500, lognormal sd = 0.05
#' res_prior3 <- SP(Data = SimulatedData, prior = list(MSY = c(1500, 0.05)))
#' @seealso [SP_production] [plot.Assessment] [summary.Assessment] [retrospective] [profile] [make_MP]
#' @export
SP <- function(x = 1, Data, AddInd = "B", rescale = "mean1", start = NULL, prior = list(),
               fix_dep = TRUE, fix_n = TRUE, LWT = NULL,
               n_seas = 4L, n_itF = 3L, Euler_Lotka = 0L, SR_type = c("BH", "Ricker"),
               silent = TRUE, opt_hess = FALSE, n_restart = ifelse(opt_hess, 0, 1),
               control = list(iter.max = 5e3, eval.max = 1e4), ...) {
  SP_(x = x, Data = Data, AddInd = AddInd, state_space = FALSE, rescale = rescale, start = start, prior = prior, 
      fix_dep = fix_dep, fix_n = fix_n, fix_sigma = TRUE,
      fix_tau = TRUE, LWT = LWT, n_seas = n_seas, n_itF = n_itF, 
      Euler_Lotka = Euler_Lotka, SR_type = SR_type, integrate = FALSE,
      silent = silent, opt_hess = opt_hess, n_restart = n_restart, control = control, inner.control = list(), ...)
}
class(SP) <- "Assess"


#' @rdname SP
#' @export
SP_SS <- function(x = 1, Data, AddInd = "B", rescale = "mean1", start = NULL, prior = list(), 
                  fix_dep = TRUE, fix_n = TRUE, fix_sigma = TRUE,
                  fix_tau = TRUE, LWT = NULL, early_dev = c("all", "index"), n_seas = 4L, n_itF = 3L,
                  Euler_Lotka = 0L, SR_type = c("BH", "Ricker"), integrate = FALSE,
                  silent = TRUE, opt_hess = FALSE, n_restart = ifelse(opt_hess, 0, 1),
                  control = list(iter.max = 5e3, eval.max = 1e4), inner.control = list(), ...) {
  SP_(x = x, Data = Data, AddInd = AddInd, state_space = TRUE, rescale = rescale, start = start, prior = prior,
      fix_dep = fix_dep, fix_n = fix_n, fix_sigma = fix_sigma,
      fix_tau = fix_tau, early_dev = early_dev, LWT = LWT, n_seas = n_seas, n_itF = n_itF, 
      Euler_Lotka = Euler_Lotka,
      SR_type = SR_type, integrate = integrate, silent = silent, opt_hess = opt_hess, n_restart = n_restart,
      control = control, inner.control = inner.control, ...)
}
class(SP_SS) <- "Assess"

#' @rdname SP
#' @export
SP_Fox <- function(x = 1, Data, ...) {
  SP_args <- c(x = x, Data = Data, list(...))
  SP_args$start$n <- 1
  SP_args$fix_n <- TRUE
  
  do.call2("SP", SP_args)
}
class(SP_Fox) <- "Assess"


#' @useDynLib SAMtool
SP_ <- function(x = 1, Data, AddInd = "B", state_space = FALSE, rescale = "mean1", start = NULL, prior = list(),
                fix_dep = TRUE, fix_n = TRUE, fix_sigma = TRUE,
                fix_tau = TRUE, early_dev = c("all", "index"), LWT = NULL, n_seas = 4L, n_itF = 3L,
                Euler_Lotka = 0L, SR_type = c("BH", "Ricker"), integrate = FALSE,
                silent = TRUE, opt_hess = FALSE, n_restart = ifelse(opt_hess, 0, 1),
                control = list(iter.max = 5e3, eval.max = 1e4), inner.control = list(), ...) {

  dependencies = "Data@Cat, Data@Ind"
  dots <- list(...)
  start <- lapply(start, eval, envir = environment())
  
  if (all(c("use_r_prior", "r_reps") %in% names(dots))) { # Backward compatibility
    if (dots$use_r_prior) Euler_Lotka <- dots$r_reps
    if ("r_prior" %in% names(start)) prior$r <- start$r_prior
  }

  early_dev <- match.arg(early_dev)
  if (any(names(dots) == "yind")) {
    yind <- eval(dots$yind)
  } else {
    ystart <- which(!is.na(Data@Cat[x, ]))[1]
    yind <- ystart:length(Data@Cat[x, ])
  }
  Year <- Data@Year[yind]
  C_hist <- Data@Cat[x, yind]
  if (any(is.na(C_hist))) stop('Model is conditioned on complete catch time series, but there is missing catch.')
  ny <- length(C_hist)
  if (rescale == "mean1") rescale <- 1/mean(C_hist)

  Ind <- lapply(AddInd, Assess_I_hist, Data = Data, x = x, yind = yind)
  I_hist <- vapply(Ind, getElement, numeric(ny), "I_hist")
  if (is.null(I_hist) || all(is.na(I_hist))) stop("No indices found.", call. = FALSE)
  
  I_sd <- vapply(Ind, getElement, numeric(ny), "I_sd")
  nsurvey <- ncol(I_hist)

  if (state_space) {
    if (early_dev == "all") est_B_dev <- rep(1, ny)
    if (early_dev == "index") {
      first_year_index <- which(apply(I_hist, 1, function(x) any(!is.na(x))))[1]
      est_B_dev <- ifelse(1:ny < first_year_index, 0, 1)
    }
  } else {
    if (nsurvey == 1 && all(AddInd == 0 | AddInd == "B")) {
      fix_sigma <- FALSE # Override: estimate sigma if there's a single survey
    }
    est_B_dev <- rep(0, ny)
  }
  
  if (is.null(prior$r) && Euler_Lotka > 0L) {
    r_samps <- r_prior_fn(x, Data, r_reps = Euler_Lotka, SR_type = SR_type)
    prior$r <- c(mean(r_samps), sd(log(r_samps)))
  }
  prior <- make_prior_SP(prior)
  
  if (is.null(LWT)) LWT <- rep(1, nsurvey)
  if (length(LWT) != nsurvey) stop("LWT needs to be a vector of length ", nsurvey)
  data <- list(model = "SP", C_hist = C_hist, rescale = rescale, I_hist = I_hist, I_sd = I_sd, I_lambda = LWT,
               fix_sigma = as.integer(fix_sigma), nsurvey = nsurvey, ny = ny,
               est_B_dev = est_B_dev, nstep = n_seas, dt = 1/n_seas, n_itF = n_itF,
               use_prior = prior$use_prior, prior_dist = prior$pr_matrix,
               sim_process_error = 0L)
  
  params <- list()
  if (!is.null(start)) {
    if (!is.null(start$FMSY) && is.numeric(start$FMSY)) params$log_FMSY <- log(start$FMSY[1])
    if (!is.null(start$MSY) && is.numeric(start$MSY)) params$MSYx <- log(start$MSY[1])
    if (!is.null(start$dep) && is.numeric(start$dep)) params$log_dep <- log(start$dep[1])
    if (!is.null(start$n) && is.numeric(start$n)) params$log_n <- log(start$n[1])
    if (!is.null(start$sigma) && is.numeric(start$sigma)) params$log_sigma <- log(start$sigma)
    if (!is.null(start$tau) && is.numeric(start$tau)) params$log_tau <- log(start$tau[1])
  }
  if (is.null(params$log_FMSY)) params$log_FMSY <- ifelse(is.na(Data@Mort[x]), 0.2, 0.5 * Data@Mort[x]) %>% log()
  if (is.null(params$MSYx)) params$MSYx <- mean(3 * C_hist * rescale) %>% log()
  if (is.null(params$log_dep)) params$log_dep <- log(1)
  if (is.null(params$log_n)) params$log_n <- log(2)
  if (is.null(params$log_sigma)) params$log_sigma <- rep(log(0.05), nsurvey)
  if (is.null(params$log_tau)) params$log_tau <- log(0.1)
  params$log_B_dev <- rep(0, ny)

  map <- list()
  if (fix_dep) map$log_dep <- factor(NA)
  if (fix_n) map$log_n <- factor(NA)
  if (fix_sigma) map$log_sigma <- factor(rep(NA, nsurvey))
  if (fix_tau) map$log_tau <- factor(NA)
  if (any(!est_B_dev)) map$log_B_dev <- factor(ifelse(est_B_dev, 1:sum(est_B_dev), NA))

  random <- NULL
  if (integrate) random <- "log_B_dev"

  info <- list(Year = Year, data = data, params = params, control = control, inner.control = inner.control)

  obj <- MakeADFun(data = info$data, parameters = info$params, hessian = TRUE,
                   map = map, random = random, DLL = "SAMtool", silent = silent)
  
  high_F <- try(obj$report(c(obj$par, obj$env$last.par[obj$env$random]))$penalty > 0 ||
                  any(is.na(obj$report(c(obj$par, obj$env$last.par[obj$env$random]))$F)), silent = TRUE)
  if (!is.character(high_F) && !is.na(high_F) && high_F) {
    for(ii in 1:10) {
      obj$par["MSYx"] <- 0.5 + obj$par["MSYx"]
      if (all(!is.na(obj$report(obj$par)$F)) && 
         obj$report(c(obj$par, obj$env$last.par[obj$env$random]))$penalty == 0) break
    }
  }
  
  mod <- optimize_TMB_model(obj, control, opt_hess, n_restart)
  opt <- mod[[1]]
  SD <- mod[[2]]
  report <- obj$report(obj$env$last.par.best)

  Yearplusone <- c(Year, max(Year) + 1)

  nll_report <- ifelse(is.character(opt), ifelse(integrate, NA, report$nll), opt$objective)
  
  report$dynamic_SSB0 <- SP_dynamic_SSB0(obj) %>% 
    structure(names = Yearplusone)
  Assessment <- new("Assessment", Model = ifelse(state_space, "SP_SS", "SP"), 
                    Name = Data@Name, conv = SD$pdHess,
                    FMSY = report$FMSY, MSY = report$MSY, 
                    BMSY = report$BMSY, VBMSY = report$BMSY, SSBMSY = report$BMSY,
                    B0 = report$K, VB0 = report$K, SSB0 = report$K, 
                    FMort = structure(report$F, names = Year),
                    F_FMSY = structure(report$F/report$FMSY, names = Year),
                    B = structure(report$B, names = Yearplusone),
                    B_BMSY = structure(report$B/report$BMSY, names = Yearplusone),
                    B_B0 = structure(report$B/report$K, names = Yearplusone),
                    VB = structure(report$B, names = Yearplusone),
                    VB_VBMSY = structure(report$B/report$BMSY, names = Yearplusone),
                    VB_VB0 = structure(report$B/report$K, names = Yearplusone),
                    SSB = structure(report$B, names = Yearplusone),
                    SSB_SSBMSY = structure(report$B/report$BMSY, names = Yearplusone),
                    SSB_SSB0 = structure(report$B/report$K, names = Yearplusone),
                    Obs_Catch = structure(C_hist, names = Year), 
                    Obs_Index = structure(I_hist, dimnames = list(Year, paste0("Index_", 1:nsurvey))),
                    Catch = structure(report$Cpred, names = Year), 
                    Index = structure(report$Ipred, dimnames = list(Year, paste0("Index_", 1:nsurvey))),
                    NLL = structure(c(nll_report, report$nll_comp, report$penalty, report$prior),
                                    names = c("Total", paste0("Index_", 1:nsurvey), "Dev", "Penalty", "Prior")),
                    info = info, obj = obj, opt = opt, SD = SD, TMB_report = report,
                    dependencies = dependencies)

  if (state_space) {
    Assessment@Dev <- structure(report$log_B_dev, names = Year)
    Assessment@Dev_type <- "log-Biomass deviations"
    Assessment@NLL <- structure(c(nll_report, report$nll_comp, report$penalty, report$prior),
                                names = c("Total", paste0("Index_", 1:nsurvey), "Dev", "Penalty", "Prior"))
  } else {
    Assessment@NLL <- structure(c(nll_report, report$nll_comp[1:nsurvey], report$penalty, report$prior),
                                names = c("Total", paste0("Index_", 1:nsurvey), "Penalty", "Prior"))
  }

  if (Assessment@conv) {
    if (state_space) {
      SE_Dev <- as.list(SD, "Std. Error")$log_B_dev
      Assessment@SE_Dev <- structure(ifelse(is.na(SE_Dev), 0, SE_Dev), names = Year)
    }
    Assessment@SE_FMSY <- SD$sd[names(SD$value) == "FMSY"]
    Assessment@SE_MSY <- SD$sd[names(SD$value) == "MSY"]
    Assessment@SE_F_FMSY <- SD$sd[names(SD$value) == "F_FMSY_final"] %>% structure(names = max(Year))
    Assessment@SE_B_BMSY <- Assessment@SE_SSB_SSBMSY <- Assessment@SE_VB_VBMSY <- 
      SD$sd[names(SD$value) == "B_BMSY_final"] %>% structure(names = max(Year))
    Assessment@SE_B_B0 <- Assessment@SE_SSB_SSB0 <- Assessment@SE_VB_VB0 <- 
      SD$sd[names(SD$value) == "B_K_final"] %>% structure(names = max(Year))
    
    catch_eq <- function(Ftarget) {
      projection_SP(Assessment, Ftarget = Ftarget, p_years = 1, p_sim = 1, obs_error = list(matrix(1, 1, 1), matrix(1, 1, 1)), 
                    process_error = matrix(1, 1, 1)) %>% slot("Catch") %>% as.vector()
    }
    Assessment@forecast <- list(catch_eq = catch_eq)
  }
  return(Assessment)
}


r_prior_fn <- function(x = 1, Data, r_reps = 1e2, SR_type = c("BH", "Ricker"), seed = x) {
  SR_type <- match.arg(SR_type)

  set.seed(x)
  M <- trlnorm(r_reps, Data@Mort[x], Data@CV_Mort[x])
  steep <- sample_steepness3(r_reps, Data@steep[x], Data@CV_steep[x], SR_type)

  max_age <- Data@MaxAge
  a <- Data@wla[x]
  b <- Data@wlb[x]
  Linf <- Data@vbLinf[x]
  K <- Data@vbK[x]
  t0 <- Data@vbt0[x]
  La <- Linf * (1 - exp(-K * (c(1:max_age) - t0)))
  Wa <- a * La ^ b

  A50 <- min(0.5 * max_age, iVB(t0, K, Linf, Data@L50[x]))
  A95 <- max(A50+0.5, iVB(t0, K, Linf, Data@L95[x]))
  mat_age <- 1/(1 + exp(-log(19) * (c(1:max_age) - A50)/(A95 - A50)))
  mat_age <- mat_age/max(mat_age)

  log_r <- vapply(1:r_reps, function(y) uniroot(Euler_Lotka_fn, c(-6, 2), M = M[y], h = steep[y], weight = Wa,
                                                mat = mat_age, maxage = max_age, SR_type = SR_type)$root, numeric(1))
  return(exp(log_r))
}

Euler_Lotka_fn <- function(log_r, M, h, weight, mat, maxage, SR_type) {
  M <- rep(M, maxage)
  NPR <- calc_NPR(exp(-M), maxage)

  SBPR <- sum(NPR * weight * mat)
  CR <- ifelse(SR_type == "BH", 4*h/(1-h), (5*h)^1.25)
  alpha <- CR/SBPR

  EL <- alpha * sum(NPR * weight * mat * exp(-exp(log_r) * c(1:maxage)))
  return(EL - 1)
}



SP_dynamic_SSB0 <- function(obj, par = obj$env$last.par.best, ...) {
  dots <- list(...)
  newdata <- obj$env$data
  newdata$C_hist <- rep(1e-8, newdata$ny)
  
  newparams <- clean_tmb_parameters(obj)
  newparams$log_dep <- log(1)
  
  obj2 <- MakeADFun(data = newdata, parameters = newparams, map = obj$env$map, 
                    random = obj$env$random, DLL = "SAMtool", silent = TRUE)
  obj2$report(par)$B
}


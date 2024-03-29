
do.call2 <- function(..., fast = TRUE) {
  if (fast && requireNamespace("Gmisc", quietly = TRUE)) {
    Gmisc::fastDoCall(...)
  } else {
    base::do.call(...)
  }
}

max <- function(..., na.rm = TRUE) {
  dots <- list(...)
  dots <- lapply(dots, function(x) x[is.finite(x)])
  dots$na.rm <- na.rm
  do.call(base::max, dots)
}

arrows <- function(...) suppressWarnings(graphics::arrows(...))

#' @importFrom graphics grid matplot
plot.default <- function(..., zero_line = FALSE) {
  if (zero_line) {
    graphics::plot.default(..., panel.first = {graphics::grid(); abline(h = 0, col = "grey")})
  } else {
    graphics::plot.default(..., panel.first = graphics::grid())
  }
}

matplot <- function(..., zero_line = FALSE) {
  if (zero_line) {
    graphics::matplot(..., panel.first = {graphics::grid(); abline(h = 0, col = "grey")})
  } else {
    graphics::matplot(..., panel.first = graphics::grid())
  }
}

#' @importFrom graphics hist legend
hist.numeric <- function(x, ...) {
  n <- length(x)
  
  # Remove NA's
  if (any(is.na(x))) {
    na_rate <- mean(is.na(x))
    x <- x[!is.na(x)]
    legend_na <- paste0(round(100 * na_rate), "% NA's")
  } else {
    legend_na <- NULL
  }
  
  # Calculate skewness NA's already removed, n is the original length of x
  skewness <- (sum((x - mean(x))^3)/n)/(sum((x - mean(x))^2)/n)^1.5
  
  # Remove outliers
  if (!is.na(skewness)) {
    if (skewness > 3) {
      max_x_plot <- quantile(x, 0.95)
      x <- x[x <= max_x_plot]
      legend_skew1 <- paste0(round(100 * mean(max_x_plot/n)), "% > ", round(max_x_plot, 2))
    } else {
      legend_skew1 <- NULL
    }
    if (skewness < -3) {
      min_x_plot <- quantile(x, 0.05)
      x <- x[x >= min_x_plot]
      legend_skew2 <- paste0(round(100 * mean(min_x_plot/n)), "% < ", round(min_x_plot, 2))
    } else {
      legend_skew2 <- NULL
    }
  } else {
    legend_skew1 <- legend_skew2 <- NULL
  }
  
  # Plot histogram
  if (all(!diff(signif(x, 3)))) { # If all identical values
    x <- signif(x, 3)
    if (all(!x)) { # if x is all zeros
      breaks <- c(-0.1, 0.1)
      xlim <- c(-1, 1)
    } else {
      breaks <- c(0.99, 1.01) * x[1]
      xlim <- c(x[1] - 0.2 * abs(x[1]), x[1] + 0.2 * abs(x[1]))
    }
    r <- graphics::hist.default(x, breaks = breaks, xlim = xlim, ...)
  } else {
    r <- graphics::hist.default(x, ...)
  }
  
  # Make legend
  legend_text <- c(legend_na, legend_skew1, legend_skew2)
  if (!is.null(legend_text)) {
    legend("topright", legend = legend_text, bty = "n", text.col = "red")
  }
  invisible(r)
}


#' Get the SAMtool vignettes
#'
#' A convenient function to open a web browser with the openMSE documentation vignettes
#' @examples
#' userguide()
#' 
#' @return Displays a browser webpage to the openMSE website.
#' @importFrom utils browseURL
#' @export
userguide <- function() browseURL("https://openmse.com")


squeeze <- function(x) (1 - .Machine$double.eps) * (x - 0.5) + 0.5
iVB <- function(t0, K, Linf, L) max(1, ((-log(1 - L/Linf))/K + t0))  # Inverse Von-B

logit <- function(p, soft_bounds = TRUE, minp = 0.01, maxp = 0.99) { #log(p/(1 - p))
  p <- squeeze(p)
  if (soft_bounds) {
    p <- pmax(p, minp)
    p <- pmin(p, maxp)
  }
  qlogis(p)
}

ilogit <- function(x) plogis(x) #1/(1 + exp(-x))

ilogitm <- function(x) {
  if (inherits(x, "matrix")) {
    return(exp(x)/apply(exp(x), 1, sum))
  } else {
    return(exp(x)/sum(exp(x)))
  }
}

ilogit2 <- function(x, ymin = 0, ymax = 1, y0 = 0.5, scale = 1) {
  location <- scale * log((ymax - ymin)/(y0 - ymin) - 1)
  return((ymax - ymin) * plogis(x, location, scale) + ymin)
}

logit2 <- function(v, ymin = 0, ymax = 1, y0 = 0.5, scale = 1) {
  location <- scale * log((ymax - ymin)/(y0 - ymin) - 1)
  p <- (v - ymin)/(ymax - ymin)
  return(qlogis(p, location, scale))
}

tiny_comp <- function(x) {
  all_zero <- all(is.na(x)) | sum(x, na.rm = TRUE) == 0
  if (!all_zero) {
    x_out <- x/sum(x, na.rm = TRUE)
    ind <- is.na(x) | x == 0
    if (any(ind)) x_out[ind] <- 1e-8
  } else {
    x_out <- x
  }
  return(x_out)
}

find_na <- function(x, na = 0) {
  all_na <- all(is.na(x))
  if (!all_na) {
    x_out <- x
    ind <- is.na(x)
    if (any(ind)) x_out[ind] <- na
  } else {
    x_out <- x
  }
  return(x_out)
}

calc_NPR <- function(surv, n_age, plusgroup = TRUE) {
  NPR <- numeric(n_age)
  NPR[1] <- 1
  for(a in 2:n_age) NPR[a] <- NPR[a-1] * surv[a-1]
  if (plusgroup) NPR[n_age] <- NPR[n_age]/(1 - surv[n_age])
  return(NPR)
}

get_F01 <- function(FM, YPR) {
  if (is.null(FM) && is.null(YPR)) stop("F01 can not be used.")
  stopifnot(length(FM) == length(YPR))
  dY_dF <- (YPR[2:length(YPR)] - YPR[2:length(YPR) - 1])/(FM[2:length(FM)] - FM[2:length(FM) - 1])
  LinInterp(dY_dF, FM[-length(FM)], xlev = 0.1 * dY_dF[1])
}

get_Fmax <- function(FM, YPR) {
  if (is.null(FM) && is.null(YPR)) stop("Fmax can not be used.")
  FM[which.max(YPR)]
}

get_FSPR <- function(FM, SPR, target = 0.4) {
  if (is.null(FM) && is.null(SPR)) stop("SPR can not be used.")
  stopifnot(length(FM) == length(SPR))
  LinInterp(SPR, FM, xlev = target)
}

LinInterp <- function(x,y,xlev,ascending=F,zeroint=F){
  if (zeroint){
    x<-c(0,x)
    y<-c(0,y)
  }
  if (ascending){
    cond <- (1:length(x)) < which.max(x)
  } else {
    cond<-rep(TRUE,length(x))
  }
  
  close <- which.min((x[cond]-xlev)^2)
  ind <- c(close, close + 2 * (x[close] < xlev) - 1)
  ind <- ind[ind <= length(x)]
  if (length(ind)==1) ind <- c(ind, ind-1)
  ind <- ind[order(ind)]
  pos <- (xlev - x[ind[1]])/(x[ind[2]] - x[ind[1]])
  y[ind[1]] + pos * (y[ind[2]] - y[ind[1]])
  
}


optimize_TMB_model <- function(obj, control = list(), use_hessian = FALSE, restart = 0, do_sd = TRUE) {
  restart <- as.integer(restart)
  if (is.null(obj$env$random) && use_hessian) h <- obj$he else h <- NULL
  low <- rep(-Inf, length(obj$par))
  upr <- rep(Inf, length(obj$par))
  
  if (any(c("U_equilibrium", "F_equilibrium") %in% names(obj$par))) {
    low[match(c("U_equilibrium", "F_equilibrium"), names(obj$par))] <- 0
  }
  if (any(names(obj$par) == "R0x") && obj$env$data$use_prior["R0"] > 1) { # R0 uniform priors need bounds
    R0x_ind <- names(obj$par) == "R0x"
    low[R0x_ind] <- log(obj$env$data$prior_dist[1, 1]) + log(obj$env$data$rescale)
    upr[R0x_ind] <- log(obj$env$data$prior_dist[1, 2]) + log(obj$env$data$rescale)
    
    # R0x start value must be in between bounds
    if (any(obj$par[R0x_ind] <= low[R0x_ind] | obj$par[R0x_ind] >= upr[R0x_ind])) {
      obj$par[R0x_ind] <- 0.95 * upr[R0x_ind]
    }
  }
  
  opt <- tryCatch(suppressWarnings(nlminb(obj$par, obj$fn, obj$gr, h, control = control, lower = low, upper = upr)),
                  error = function(e) as.character(e))
  
  if (do_sd) {
    SD <- get_sdreport(obj)
    
    if (!SD$pdHess && restart > 0) {
      if (!is.character(opt)) obj$par <- opt$par * exp(rnorm(length(opt$par), 0, 1e-3))
      Recall(obj, control, use_hessian, restart - 1, do_sd)
    } else {
      return(list(opt = opt, SD = SD))
    }
  } else {
    return(list(opt = opt, SD = NULL))
  }
}


check_det <- function(h, abs_val = 0.1, is_null = TRUE) {
  if (is.null(h)) return(is_null)
  det_h <- det(h) %>% abs()
  !is.na(det_h) && det_h < abs_val
}


get_sdreport <- function(obj, getReportCovariance = FALSE) {
  old_warn <- options()$warn
  options(warn = -1)
  on.exit(options(warn = old_warn))
  
  par.fixed <- obj$env$last.par.best
  if (is.null(obj$env$random)) {
    h <- obj$he(par.fixed)
    if (any(is.na(h)) || any(is.infinite(h)) || det(h) <= 0) {
      h <- NULL
    } else {
      res <- sdreport(obj, par.fixed = par.fixed, hessian.fixed = h, getReportCovariance = getReportCovariance)
      #if (!res$pdHess) h <- NULL
    }
  } else {
    par.fixed <- par.fixed[-obj$env$random] 
    h <- NULL
  }
  
  if (is.null(h) || check_det(h)) {  # If hessian doesn't exist or marginal positive-definite cases, with -0.1 < det(h) <= 0
    h <- optimHess(par.fixed, obj$fn, obj$gr)
    res <- sdreport(obj, par.fixed = par.fixed, hessian.fixed = h, getReportCovariance = getReportCovariance)
  }
  
  if (check_det(h) && !res$pdHess && requireNamespace("numDeriv", quietly = TRUE)) {
    h <- numDeriv::jacobian(obj$gr, par.fixed)
    res <- sdreport(obj, par.fixed = par.fixed, hessian.fixed = h, getReportCovariance = getReportCovariance)
  }
  
  if (all(is.na(res$cov.fixed)) && res$pdHess) {
    if (!is.character(try(chol(h), silent = TRUE))) res$cov.fixed <- chol2inv(chol(h))
  }
  
  res$env$corr.fixed <- cov2cor(res$cov.fixed) %>% round(3) %>% 
    structure(dimnames = list(names(res$par.fixed), names(res$par.fixed)))
  
  return(res)
}

sdreport_int <- function(object, select = c("all", "fixed", "random", "report"), p.value = FALSE, ...) {
  if (is.character(object)) return(object)
  select <- match.arg(select, several.ok = TRUE)
  if ("all" %in% select) select <- c("fixed", "random", "report")
  if ("report" %in% select) {
    AD <- TMB::summary.sdreport(object, "report", p.value = p.value) %>% cbind("Gradient" = NA_real_)
  } else AD <- NULL

  if ("fixed" %in% select) {
    fix <- TMB::summary.sdreport(object, "fixed", p.value = p.value) %>% cbind("Gradient" = as.vector(object$gradient.fixed))
  } else fix <- NULL

  if (!is.null(object$par.random) && "random" %in% select) {
    random <- TMB::summary.sdreport(object, "random", p.value = p.value) %>% cbind("Gradient" = rep(NA_real_, length(object$par.random)))
  } else {
    random <- NULL
  }

  out <- rbind(AD, fix, random)
  out <- cbind(out, "CV" = ifelse(abs(out[, "Estimate"]) > 0, out[, "Std. Error"]/abs(out[, "Estimate"]), NA_real_))
  rownames(out) <- make_unique_names(rownames(out))
  return(out)
}

# Remove map attributes
clean_tmb_parameters <- function(obj) {
  lapply(obj$env$parameters, function(x) if (!is.null(attr(x, "map"))) attr(x, "shape") else x)
}

# Call from inside generate_plots() and summary.Assessment
assign_Assessment_slots <- function(Assessment = NULL) {
  if (is.null(Assessment)) Assessment <- get("Assessment", envir = parent.frame(), inherits = FALSE)
  Nslots <- length(slotNames(Assessment))
  for(i in 1:Nslots) {
    assign(slotNames(Assessment)[i], slot(Assessment, slotNames(Assessment)[i]), envir = parent.frame())
  }
  invisible()
}

# For SCA, if there are fewer years of CAA/CAL than Year, add NAs to matrix
expand_comp_matrix <- function(Data, comp_type = c("CAA", "CAL")) {
  comp_type <- match.arg(comp_type)
  ny <- length(Data@Year)

  comp <- slot(Data, comp_type)
  dim_comp <- dim(comp)
  ny_comp <- dim_comp[2]
  if (ny_comp < ny) {
    newcomp <- array(NA, dim = c(1, ny, dim_comp[3]))
    ind_new <- ny - ny_comp + 1
    newcomp[ , ind_new:ny, ] <- comp
    slot(Data, comp_type) <- newcomp
  } else if (ny_comp > ny) {
    ind_new <- ny_comp - ny + 1
    newcomp <- comp[, ind_new:ny, ]
    slot(Data, comp_type) <- newcomp
  }
  return(Data)
}

sample_steepness3 <- function(n, mu, cv, SR_type = c("BH", "Ricker")) {
  SR_type <- match.arg(SR_type)
  if (n == 1) {
    return(mu)
  } else if (SR_type == "BH") {
    sigma <- mu * cv
    mu.beta.dist <- (mu - 0.2)/0.8
    sigma.beta.dist <- sigma/0.8
    beta.par <- MSEtool::derive_beta_par(mu.beta.dist, sigma.beta.dist)
    h.transformed <- rbeta(n, beta.par[1], beta.par[2])
    h <- 0.8 * h.transformed + 0.2
    h[h > 0.99] <- 0.99
    h[h < 0.2] <- 0.2
    return(h)
  } else {
    sigma <- mu * cv
    mu.lognorm.dist <- mconv(mu - 0.2)
    sigma.lognorm.dist <- sigma

    h.transformed <- trlnorm(n, mconv(mu.lognorm.dist, sigma.lognorm.dist), sdconv(mu.lognorm.dist, sigma.lognorm.dist))
    h <- h.transformed + 0.2
    h[h < 0.2] <- 0.2
    return(h)
  }
}

Assess_I_hist <- function(xx, Data, x, yind) {
  if (xx == 0 || xx == "B") {

    I_hist <- Data@Ind[x, yind]
    I_sd <- sdconv(1, Data@CV_Ind[x, yind])
    I_units <- 1L

  } else if (xx == "SSB" && .hasSlot(Data, "SpInd")) {

    I_hist <- Data@SpInd[x, yind]
    I_sd <- sdconv(1, Data@CV_SpInd[x, yind])
    I_units <- 1L

  } else if (xx == "VB" && .hasSlot(Data, "VInd")) {

    I_hist <- Data@VInd[x, yind]
    I_sd <- sdconv(1, Data@CV_VInd[x, yind])
    I_units <- 1L

  } else if (is.numeric(xx) && xx > 0 && .hasSlot(Data, "AddInd") && xx <= dim(Data@AddInd)[2]) {

    I_hist <- Data@AddInd[x, xx, yind]
    I_sd <- sdconv(1, Data@CV_AddInd[x, xx, yind])
    if (.hasSlot(Data, "AddIunits") && !is.na(Data@AddIunits[xx])) {
      I_units <- Data@AddIunits[xx]
    } else {
      I_units <- 1L
    }
  }

  if (exists("I_hist", inherits = FALSE)) {
    I_hist[!is.na(I_hist) & I_hist <= 0] <- NA_real_
    if (all(is.na(I_sd)) || all(!I_sd, na.rm = TRUE)) {
      if (!is.null(Data@Obs$Isd[x])) {
        I_sd <- rep(Data@Obs$Isd[x], length(yind))
      } else {
        I_sd <- rep(0.2, length(yind))
      }
    }
  } else {
    I_hist <- I_sd <- I_units <- NULL
  }
  return(list(I_hist = I_hist, I_sd = I_sd, I_units = I_units))
}


dev_AC <- function(n, mu = 1, stdev, AC, seed, chain_start) {
  if (!missing(seed)) set.seed(seed)
  
  log_mean <- log(mu) - 0.5 * stdev^2 * (1 - AC)/sqrt(1 - AC^2) #http://dx.doi.org/10.1139/cjfas-2016-0167
  samp <- rnorm(n, log_mean, stdev)
  out <- numeric(n)
  if (missing(chain_start)) {
    out[1] <- samp[1]
  } else {
    out[1] <- chain_start * AC + samp[1] * sqrt(1 - AC^2)
  }
  for(i in 2:n) out[i] <- out[i-1] * AC + samp[i] * sqrt(1 - AC^2)
  return(out)
}


# Calculates the recruitment from the SSB or SSB/R
MesnilRochet_SR <- function(x, Shinge, Rmax, gamma, isSB = TRUE) {
  c1 <- Shinge^2 + 0.25 * gamma^2
  K <- sqrt(c1)
  beta <- Rmax/(Shinge + K)
  
  if (isSB) { # x is the SSB
    c2 <- (x - Shinge)^2 + 0.25 * gamma^2
    c3 <- x + K - sqrt(c2)
    Rpred <- beta * c3
  } else { # x is SSBpR
    num <- 2 * K/x/beta - 2 * (Shinge + K)
    den <- 1/x/x/beta/beta - 2/x/beta
    Se <- num/den
    Rpred <- ifelse(1/x > 2 * beta, 0, Se/x)
  }
  return(Rpred)
}

# Calculates SPRcrash from unfished SSB/R
MesnilRochet_SPRcrash <- function(SSBpR0, Shinge, Rmax, gamma) {
  c1 <- Shinge^2 + 0.25 * gamma^2
  K <- sqrt(c1)
  beta <- Rmax/(Shinge + K)
  SSBpR_crash <- 0.5/beta
  SSBpR_crash/SSBpR0
}

make_prior <- function(prior, nsurvey, SR_rel, dots = list(), msg = TRUE) { # log_R0, log_M, h, q
  if (!length(prior) && !is.null(dots$priors)) prior <- dots$priors
  
  no_index <- nsurvey == 0
  if (no_index) nsurvey <- 1 # Use only on next two lines
  var_names <- c("R0", "h", "log_M", paste0("q_", 1:nsurvey))
  use_prior <- rep(0L, nsurvey + 3) %>% structure(names = var_names)
  pr_matrix <- matrix(NA_real_, nsurvey + 3, 2) %>% 
    structure(dimnames = list(var_names, c("par1", "par2")))
  
  if (!is.null(prior$R0)) {
    if (length(prior$R0) == 2) prior$R0 <- c(1, prior$R0) # Backwards compatibility
    use_prior[1] <- as.integer(prior$R0[1]) # 1 - lognormal, 2 - uniform on log-R0, 3 - uniform on R0
    
    if (msg) {
      message(
        switch(
          use_prior[1],
          "1" = "Lognormal prior for R0 found.",
          "2" = "Uniform prior for log(R0) found.",
          "3" = "Uniform prior for R0 found."
        )
      )
    }
    
    if (use_prior[1] == 1) {
      pr_matrix[1, ] <- c(log(prior$R0[2]), prior$R0[3])
    } else {
      pr_matrix[1, ] <- prior$R0[2:3]
      if (prior$R0[3] <= prior$R0[2]) stop("The upper bound of the R0 prior is less than the lower bound.")
    }
  }
  if (!is.null(prior$h)) {
    if (msg) message("Prior for steepness (h) found.")
    use_prior[2] <- 1L
    if (SR_rel == 1) { #BH
      a <- MSEtool::alphaconv(1.25 * prior$h[1] - 0.25, 1.25 * prior$h[2])
      b <- MSEtool::betaconv(1.25 * prior$h[1] - 0.25, 1.25 * prior$h[2])
      
      if (a <= 0) stop("The alpha parameter < 0 (beta distribution) for the steepness prior. Try reducing the prior SD.", call. = FALSE)
      if (b <= 0) stop("The beta parameter < 0 (beta distribution) for the steepness prior. Try reducing the prior SD.", call. = FALSE)
      pr_matrix[2, ] <- c(a, b)
    } else { #Ricker
      pr_matrix[2, ] <- prior$h
    }
  }
  if (!is.null(prior$M)) {
    if (msg) message("Prior for log_M found.")
    use_prior[3] <- 1L
    pr_matrix[3, ] <- c(log(prior$M[1]), prior$M[2])
  }
  if (!no_index && !is.null(prior$q)) {
    if (msg) message("Prior for q found.")
    if (nsurvey == 1) {
      if (is.matrix(prior$q)) {
        pr_matrix[4, ] <- prior$q[1, ]
      } else {
        pr_matrix[4, ] <- prior$q
      }
      use_prior[4] <- !is.na(pr_matrix[4, 1])
    } else if (is.matrix(prior$q) && nrow(prior$q) == nsurvey) {
      pr_matrix[4:(4+nsurvey-1), ] <- prior$q[1:nsurvey, ]
      use_prior[4:(4+nsurvey-1)] <- !is.na(pr_matrix[4:(4+nsurvey-1), 1])
    } else {
      stop("prior$q should be a matrix of ", nsurvey, "rows and 2 columns.")
    }
    if (any(pr_matrix[4:(4+nsurvey-1), 1] <= 0, na.rm = TRUE)) stop("Ensure q prior mean is greater than > 0.")
    pr_matrix[4:(4+nsurvey-1), 1] <- log(pr_matrix[4:(4+nsurvey-1), 1])
  }
  return(list(use_prior = use_prior, pr_matrix = pr_matrix))
}

make_prior_SP <- function(prior) {
  var_names <- c("r", "MSY")
  pr_matrix <- matrix(NA_real_, 2, 2) %>% 
    structure(dimnames = list(var_names, c("par1", "par2")))
  use_prior <- rep(0L, 2) %>% structure(names = var_names)
  
  if (!is.null(prior$r)) {
    pr_matrix[1, ] <- c(log(prior$r[1]), prior$r[2])
    use_prior[1] <- 1L
  }
  if (!is.null(prior$MSY)) {
    pr_matrix[2, ] <- c(log(prior$MSY[1]), prior$MSY[2])
    use_prior[2] <- 1L
  }
  list(use_prior = use_prior, pr_matrix = pr_matrix)
}

solve_F <- function(N, M, plusgroup = TRUE) {
  FM <- array(NA_real_, dim(M))
  nyears <- nrow(M)
  n_age <- ncol(M)
  for(y in 1:nyears) {
    for(a in 3:n_age - 2) FM[y, a] <- -log(N[y+1,a+1]/N[y,a]/exp(-M[y,a]))
    if (plusgroup) {
      FM[y,n_age] <- FM[y,n_age-1] <- -log(N[y+1,n_age]/(N[y,n_age] * exp(-M[y,n_age]) + 
                                                           N[y,n_age-1] * exp(-M[y,n_age-1])))
    } else {
      FM[y,n_age] <- FM[y,n_age-1] <- -log(N[y+1,n_age]/N[y,n_age-1]/exp(-M[y,n_age-1]))
    }
  }
  FM[is.na(FM) | FM < 0] <- 1e-8
  return(FM)
}



message <- function(...) {
  if (requireNamespace("usethis", quietly = TRUE)) {
    dots <- list(...)
    do.call(c, dots) %>% paste0(collapse = "") %>% usethis::ui_done()
  } else {
    base::message(...)
  }
}

message_info <- function(...) {
  if (requireNamespace("usethis", quietly = TRUE)) {
    dots <- list(...)
    do.call(c, dots) %>% paste0(collapse = "") %>% usethis::ui_info()
  } else {
    base::message(...)
  }
}

message_oops <- function(...) {
  if (requireNamespace("usethis", quietly = TRUE)) {
    dots <- list(...)
    do.call(c, dots) %>% paste0(collapse = "") %>% usethis::ui_oops()
  } else {
    base::message(...)
  }
}

warning <- function(...) {
  if (requireNamespace("usethis", quietly = TRUE)) {
    dots <- list(...)
    do.call(c, dots) %>% paste0(collapse = "") %>% usethis::ui_warn()
  } else {
    base::warning(...)
  }
}


stop <- function(..., call. = TRUE, domain = NULL) {
  if (requireNamespace("usethis", quietly = TRUE)) {
    dots <- list(...)
    do.call(c, dots) %>% paste0(collapse = "") %>% usethis::ui_stop()
  } else {
    base::stop(..., call. = call., domain = domain)
  }
}


## ---- echo = FALSE, include = FALSE-------------------------------------------
library(SAMtool)

## ----set options, echo = FALSE------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>", fig.align = "center")
#knitr::opts_chunk$set(dpi=85)
#options(width = 650)

## ---- eval = FALSE------------------------------------------------------------
#  SCA_assessment <- SCA(Data = MSEtool::SimulatedData, fix_h = FALSE, ...)

## ---- eval = FALSE------------------------------------------------------------
#  class?Assessment

## ---- eval = FALSE------------------------------------------------------------
#  browseVignettes("SAMtool")

## ---- eval = FALSE------------------------------------------------------------
#  plot(SCA_assessment) # By default, also saves figures in a temporary directory for viewing. The directory can be changed to a user's filespace of choice
#  summary(SCA_assessment)

## ---- echo = FALSE------------------------------------------------------------
SCA_assessment <- SCA(x = 3, Data = MSEtool::SimulatedData, fix_h = FALSE)
summary(SCA_assessment)[1:3]

## ---- eval = FALSE------------------------------------------------------------
#  retrospective(SCA_assessment, nyr = 5) # Retrospective analysis going back 5 years from current year
#  profile(SCA_result, R0 = seq(0.75, 1.25, 0.025), h = seq(0.95, 1, 2.5e-3)) # Joint profile over grid of R0 and steepness

## ---- echo = FALSE------------------------------------------------------------
retrospective(SCA_assessment, nyr = 5, figure = FALSE)

## ---- echo = FALSE, fig.width = 5, fig.height = 4-----------------------------
par(mar = c(5,5,3,1))
Brel <- seq(0, 1, length.out = 200)
plot(Brel, SAMtool::HCRlin(Brel, 0.1, 0.4), xlab = expression(Estimated~~SSB/SSB[0]), ylab = "TAC adjustment factor \n(proportion of FMSY catch)", main = "40-10 harvest control rule", type = "l", col = "blue")
abline(v = c(0.1, 0.4), col = "red", lty = 2)

## -----------------------------------------------------------------------------
avail("MP", package = "SAMtool")

## ---- eval = FALSE------------------------------------------------------------
#  SCA_MSY_ <- make_MP(SCA, HCR_MSY, diagnostic = "full")
#  SCA_4010_ <- make_MP(SCA, HCR40_10, diagnostic = "full")
#  myMSE <- MSEtool::runMSE(OM = MSEtool::testOM, MPs = c("FMSYref", "AvC", "SCA_MSY_", "SCA_4010_"))
#  MSEtool::Tplot(myMSE)

## ---- eval = FALSE------------------------------------------------------------
#  SCA_MSY_Ricker_fixsteep <- make_MP(SCA, HCR_MSY, SR = "Ricker", fix_h = TRUE)

## ---- eval = FALSE------------------------------------------------------------
#  prelim_AM(MSEtool::testOM, DD_TMB, ...)
#  #> Running DD_TMB with 3 simulations for testOM.
#  #> Assessments complete.
#  #> Total time to run 3 assessments: 0.1 seconds
#  #> 0 of 3 simulations (0%) failed to converge.

## ---- eval = FALSE------------------------------------------------------------
#  SCA_MSY_ <- make_MP(SCA, HCR_MSY, diagnostic = "full")

## ---- eval = FALSE------------------------------------------------------------
#  diagnostic(myMSE)
#  retrospective_AM(myMSE, MP = "SCA_MSY_", sim = 3)


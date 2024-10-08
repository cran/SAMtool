% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/SAMtool-package.R
\docType{package}
\name{SAMtool-package}
\alias{SAMtool-package}
\alias{SAMtool}
\title{Stock Assessment Methods Toolkit}
\description{
Simulation tools for closed-loop simulation are provided for the 'MSEtool' operating model to inform data-rich fisheries.
SAMtool provides an OM conditioning model, assessment models of varying complexity with standardized reporting, diagnostic tools for evaluating
assessments within closed-loop simulation, and helper functions for building more complex operating models and model-based management procedures.
}
\section{How to use SAMtool}{

The main features of SAMtool are the assessment models and the ability to make model-based management procedures by combining
assessment models with harvest control rules. Such MPs can be used and tested in management strategy evaluation
with MSEtool operating models. An overview of these features is available
on the \href{https://openmse.com/features-assessment-models/}{openMSE} website.

The \code{\link[=RCM]{RCM()}} (Rapid Conditioning Model) can be used to condition operating models from real data.

The following articles are available on the openMSE website:
\itemize{
\item \href{https://openmse.com/features-assessment-models/}{Description of assessment models}
\item \href{https://openmse.com/tutorial-rcm/}{General overview of RCM}
}

The function documentation can be viewed \href{https://samtool.openmse.com/reference/index.html}{online}.
}

\references{
Carruthers, T.R., Punt, A.E., Walters, C.J., MacCall, A.,
McAllister, M.K., Dick, E.J., Cope, J. 2014. Evaluating methods for setting
catch limits in data-limited fisheries. Fisheries Research. 153: 48-68.

Carruthers, T.R., Kell, L.T., Butterworth, D.S., Maunder, M.N., Geromont,
H.F., Walters, C., McAllister, M.K., Hillary, R., Levontin, P., Kitakado,
T., Davies, C.R. Performance review of simple management procedures. ICES
Journal of Marine Science. 73: 464-482.
}
\seealso{
Useful links:
\itemize{
  \item \url{https://openmse.com}
  \item \url{https://samtool.openmse.com}
  \item \url{https://github.com/Blue-Matter/SAMtool}
  \item Report bugs at \url{https://github.com/Blue-Matter/SAMtool/issues}
}

}
\author{
Quang Huynh \email{quang@bluematterscience.com}

Tom Carruthers \email{tom@bluematterscience.com}

Adrian Hordyk \email{adrian@bluematterscience.com}
}
\keyword{evaluation}
\keyword{fisheries}
\keyword{management}
\keyword{strategy}

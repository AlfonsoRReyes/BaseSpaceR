\name{ResponseStatus-class}
\Rdversion{1.1}
\docType{class}

\alias{ResponseStatus-class}
\alias{ResponseStatus}

\alias{show,ResponseStatus-method}


\title{Class \code{"ResponseStatus"}}

\description{
  The ResponseStatus class is used internally to manage the status
  messages returned by the REST service.
}

\section{Objects from the Class}{
  Objects can be created by calls of the form \code{ResponseStatus()}.
  \code{ResponseStatus()} creates an \code{ResponseStatus} instances...
}

\section{Methods}{
  \describe{
    \item{success}{\code{signature(x = "ServiceURI")}: Returns
      \code{TRUE} if the HTTP status is 2xx. }
    \item{show}{\code{signature(object = "ServiceURI")}: ... }
  }
}
\author{
  Adrian Alexa
}

\examples{
showClass("ResponseStatus")
}
\keyword{classes}
\keyword{methods}

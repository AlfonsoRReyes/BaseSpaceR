\name{BaseSpaceR-package}
\alias{BaseSpaceR-package}
\alias{BaseSpaceR}

\docType{package}

\title{R SDK for BaseSpace RESTful API}

\description{
  The \code{BaseSpaceR} package provides a rich R interface to
  Illumina's BaseSpace cloud computing environment, enabling the fast
  development of data analysis and visualisation tools.
}

\details{
  BaseSpace is Illumina's next-generation sequencing cloud computing
  environment designed with biologists in mind. Researcher can easily
  store, analyze, collaborate, and share genetic data
  (https://basespace.illumina.com).
  
  BaseSpaceR is a SDK ofering methods and data structures for working
  with the data resources BaseSpace REST API exposes.
  
  Features include:
  \itemize{
    \item Persistent connection with the REST server.
    \item Support for the REST API query parameters.
    \item Vectorized operations in line with the R semantic. Allows for
    queries across multiple Projects, Samples, AppResults, Files, etc.
    \item S4 class system used to represent the BaseSpace data model.
    \item Portability on most platforms: Linux, Windows and Mac OS X.
  }
}

\author{
  Adrian Alexa
  
  Maintainer: Adrian Alexa \email{aalexa@illumina.com}
}

\references{
  \describe{
    \item{BaseSpace}{\url{https://basespace.illumina.com}}
    \item{BaseSpace API}{\url{https://developer.basespace.illumina.com}}
  }
}

\seealso{
  \describe{
    \item{\code{\link{AppAuth-class}}}{for details on how to establish a
      connection with the BaseSpace server.}
    \item{\code{\link{Response-class}}}{for details on the structure of the
      objects and the interface used by the API.}
    \item{\code{\link{Users-class}}, \code{\link{Genomes-class}},
      \code{\link{Runs-class}}, \code{\link{Projects-class}},
      \code{\link{Samples-class}}, \code{\link{Files-class}}
      and \code{\link{AppResults-class}}}{for
      details on various resources supported by the API.}
  }
}


\keyword{package}

\name{Files-class}
\Rdversion{1.1}

\docType{class}

\alias{fileItem}
\alias{fileItem-class}
\alias{fileCollection}
\alias{fileCollection-class}

\alias{FilesSummary-class}
\alias{Files-class}
\alias{Files}
\alias{Files,missing-method}
\alias{Files,AppAuth-method}
\alias{Files,FilesSummary-method}

\alias{listFiles}
\alias{listFiles,AppAuth-method}
\alias{listFiles,Runs-method}
\alias{listFiles,Samples-method}
\alias{listFiles,AppResults-method}

\alias{getFiles,AppAuth-method}
\alias{getFiles}
\alias{putFiles,AppAuth-method}
\alias{putFiles}



\title{\code{Files} and \code{FilesSummary} objects}

\description{
  Classes and methods to handle the Files resource.
}


\details{
  The Files resource provides access to files stored in BaseSpace. A file should be seen
  as a data stream and associated attributes (date created, size, type, etc.).

  Files are associated with specific Runs, Samples, or AppResults and the Files resource
  provides the interface for manipulating these files. 
}



\references{
  https://developer.basespace.illumina.com/docs/content/documentation/rest-api/api-reference
}
\author{
  Adrian Alexa
}


\seealso{
  \code{\linkS4class{AppAuth}}, \code{\linkS4class{Runs}},
  \code{\linkS4class{Samples}} and \code{\linkS4class{AppResults}}.
}

\examples{

data(aAuth)


## get one AppResult
reseq <- AppResults(listAppResults(aAuth, projectId = 12, Limit = 1))

f <- listFiles(reseq)
TotalCount(f)
Name(f)


identical(f, listFiles(aAuth, appResultId = Id(reseq)))

## list only the BAM files
f <- listFiles(aAuth, appResultId = Id(reseq), Extensions = ".bam")
Name(f)


}
\keyword{classes}
\keyword{methods}

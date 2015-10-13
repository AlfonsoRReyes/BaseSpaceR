\name{FilesMethods}
\Rdversion{1.1}

\docType{methods}

\alias{getBAMs}
\alias{getIndexedBam}
\alias{getBAMs,AppResults-method}


\title{High-level methods for \code{Files} objects and related}

\description{
  Methods to handle various files types.
}


\details{
  The Files resource provides access to files stored in BaseSpace. A file should be seen
  as a data stream and associated attributes (date created, size, type, etc.).

  For known file types (.bam, .vcf, etc.) we offer wrappers to 'map'
  this objects to various Bioconductor objects.
}


\references{
  https://developer.basespace.illumina.com/docs/content/documentation/rest-api/api-reference
}
\author{
  Adrian Alexa
}


\seealso{
  \code{\linkS4class{AppAuth}}, \code{\linkS4class{AppResults}} and
  \code{\linkS4class{Files}}
}

\examples{

data(aAuth)


## get one AppResult
reseq <- AppResults(listAppResults(aAuth, projectId = 21383369, Limit = 1))

f <- listFiles(reseq)
TotalCount(f)
Name(f)

## list only the BAM files
f <- listFiles(aAuth, appResultId = Id(reseq), Extensions = ".bam")
Name(f)

## construct the BAMFile
##...


}
\keyword{methods}

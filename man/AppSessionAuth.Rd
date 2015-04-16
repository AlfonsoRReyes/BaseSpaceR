\name{AppSessionAuth-class}
\Rdversion{1.1}

\docType{class}

\alias{AppSessionAuth-class}
\alias{authNativeClient}
\alias{authWebClient}

\title{\code{AppSessionAuth} class}

\description{
  Extension of the AppAuth class...
}


\references{
  https://developer.basespace.illumina.com/docs/content/documentation/rest-api/api-reference
}
\author{
  Adrian Alexa
}


\seealso{
  \code{\linkS4class{Runs}}, \code{\linkS4class{Projects}},
  \code{\linkS4class{Samples}}, etc. for examples of objects using the
  \code{AppAuth} handler.
  
  \code{\linkS4class{ServiceURI}} for a low-level object managing the
  REST calls.
}

\examples{
showClass("AppAuth")

## using the OAuth v2 workflow 
\dontrun{
## paste your client_id and client_secret here
myAppClientId = ""
myAppClientSecret = ""

## instantiate a new AppAuth object
myHandle <- AppAuth(client_id = myAppClientId,
                    client_secret = myAppClientSecret,
                    scope = "browse global")

## Open the showed URI in a browser and perform the authentication.

requestAccessToken(myHandle)
hasAccess(myHandle)

}
}

\keyword{classes}
\keyword{methods}

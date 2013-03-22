\name{AppAuth-class}
\Rdversion{1.1}

\docType{class}

\alias{AppAuth-class}
\alias{AppAuth}

\alias{initializeAuth,AppAuth-method}
\alias{initializeAuth}

\alias{requestAccessToken,AppAuth-method}
\alias{requestAccessToken}

\alias{hasAccess,AppAuth-method}
\alias{hasAccess}


\title{\code{AppAuth} class}

\description{
  Class to manage client's communication and permissions with BaseSpace REST serve.
}


\section{Methods}{
  \describe{
    \item{initializeAuth}{\code{signature(x = "AppAuth")}: ... }
    \item{requestAccessToken}{\code{signature(x = "AppAuth")}: ... }
    \item{hasAccess}{\code{signature(x = "AppAuth")}: ... }
  }
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

## load an AppAuth instance containing a pre-generated access token
data(aAuth)
aAuth

hasAccess(aAuth)

## new AppAuth instance using a pre-generated access token
my_access_token <- "eee44c28ba0e43a1badb85c5ce7bb94d"
myHandle <- AppAuth(access_token = my_access_token)
myHandle

Users(myHandle)


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

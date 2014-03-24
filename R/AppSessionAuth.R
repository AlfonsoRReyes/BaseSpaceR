############################################################           
##  A p p S e s s i o n A u t h     C L A S S
############################################################           

## AppSessionAuth class extends the AppAuth class by
## keeping track of the AppSessionId
## This class will be used for Web and Native Apps.
## It is mainly use fo dispatchment... we might specialize methods for it. 

.AppSessionAuth <- setRefClass("AppSessionAuth",
                               contains = "AppAuth",

                               fields = list(appsession_id = "character"),

                               methods =  list(
                                 show = function() {
                                   callSuper()
                                   cat("AppSessionId:     ", appsession_id, "\n")
                                 }))


######################################################################

##How do we instantiate for Native App ... what input do we have?
##How do we instantiate for Web Apps ...


##############################
## WEB APP 
## Function to authenticate the client once an App was lauched.
## Returns an AppSessionAuth handler with a valid access tocken or NULL
authWebClient <- function(appTriggeringURI,
                          client_id = character(),
                          client_secret = character(),
                          uri = ServiceURI(), ...,
                          resource = "oauthv2/token") {
  
  ## get the redirect URI and the HTTP parameters from the triggered URI
  turi <- tokenizeURI(appTriggeringURI)
  
  ## send request for the verification code
  res <- POSTForm(uri, resource = resource,
                  .params = list(client_id = client_id,
                    client_secret = client_secret,
                    code = turi$param["authorization_code"],
                    redirect_uri = turi$URL,
                    grant_type = "authorization_code"))

  ## save the response status
  response_status <- .extractStatus(res)
  
  ## fail nicely
  if(!success(response_status, OK = TRUE)) {
    ## not much we can do here since we can't recover from this ...
    stop("Authorisation failed!\n", .printFail(response_status))
  }

  cat(" Access token successfully acquired!\n\n")
  ## instance of AppSessionAuth class
  app <- .AppSessionAuth(client_id = client_id,
                         client_secret = client_secret,
                         uri = uri,
                         ## the AppSession Id is found in param$appsessionuri
                         appsession_id = id_from_href(turi$param["appsessionuri"]),
                         access_token = res$body$access_token)
  
  ## set the curl handler to enable persistant connections
  app$set_handle()

  return(app)
}



##############################
## NATIVE APP 
## Function to authenticate the client from within a Native App.
## Returns an AppSessionAuth handler with a valid access tocken or NULL
authNativeClient <- function(client_id = character(),
                             client_secret = character(),
                             access_token = character(),
                             appsession_id = character(), ## do we get this?
                             uri = ServiceURI()){

  ## we might need to do some processing here, but for now is just a trivial wrapper

  ## instance of AppSessionAuth class
  app <- .AppSessionAuth(client_id = client_id,
                         client_secret = client_secret,
                         uri = uri,
                         access_token = access_token,
                         appsession_id = appsession_id)
  
  ## set the curl handler to enable persistant connections
  app$set_handle()
  
  return(app)
}


##############################
## Constructor - user level
## should we export .AppSessionAuth() ? 


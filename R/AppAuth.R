############################################################           
##  A p p A u t h    C L A S S
############################################################           

setClassUnion("CURLHandleORNULL", c("NULL", "CURLHandle"))

.AppAuth <- setRefClass("AppAuth",
                        fields = list(
                          client_id = "character", 
                          client_secret = "character", 
                          ## address of the REST server (root url + version)
                          uri = "ServiceURI", 
                          ## stores the last response from the server during the authentication
                          response = "list",
                          ## stores the status of the last response from the server
                          response_status = "ResponseStatus",  
                          ## curl handler to allow for persistant connections
                          curl_handle = "CURLHandleORNULL",
                          ## the access tocken 
                          access_token = "character"),

                        methods = list(
                          
                          show = function() {
                            'Method for printing the AppAuth class.'
                            cat("Object of class", classLabel(class(.self)), "with:\n")
                            cat("\nClient Id:      ", client_id, "\n")
                            cat("Client Secret: ", client_secret, "\n")
                            cat("\nServer\n")
                            methods::show(uri)
                            cat("\nAuthorized:     ", (length(access_token) > 0L) && has_access(), "\n")
                          },

                          showResponse = function() {
                            cat(toJSON(response, pretty = TRUE), "\n")
                          },
                          
                          set_handle = function() {
                            'Sets the curl handle.'
                            if(length(access_token) == 0L) 
                              stop("No access tocken available! Run initializeAuth() to start the authentication!")
                            
                            curl_handle <<- getCurlHandle(httpheader = c("x-access-token" = access_token))
                          },
                          
                          dup_handle = function(headerFields) {
                            'Duplicates the current curl handle.'
                            if (is.null(curl_handle)) 
                              set_handle()
                            
                            if(missing(headerFields))
                              return(dupCurlHandle(curl = curl_handle))
                                                        
                            dupCurlHandle(curl = curl_handle,
                                          httpheader = c("x-access-token" = access_token, headerFields))
                          },

                          initializeAuth = function(scope = "browse global",
                            resource = "oauthv2/deviceauthorization",
                            useBrowser = TRUE) {
                            'Method that initialize the authentication process.
                             It is automaticaly run by the class generic constructor.
                            '
                            ## send request for the verification code
                            res <- POSTForm(uri, resource = resource,
                                            .params = list(response_type = "device_code",
                                              client_id = client_id, scope = scope))

                            
                            ## store the response status
                            response_status <<- .extractStatus(res)
                            
                            ## store the body in the .self$response
                            response <<- res$body

                            ## fail nicely ...
                            if(!success(response_status)) {
                              warning("Initialization for the device failed!\n",
                                      .printFail(response_status),
                                      "Use showResponse() method to print the response body.")
                              return(invisible(as.integer(Hstatus(response_status))))
                            }

                            ## since the request is succesful we should reset
                            ## the current access_token if set
                            access_token <<- character()
                            
                            ## present the verification URI
                            if(useBrowser) {
                              cat("\n Launching browser for OAuth authentication...\n")
                              browseURL(response$verification_with_code_uri)
                            } else {
                              cat("\nPerform OAuth authentication using the following URI:\n")
                              cat("\t", response$verification_with_code_uri, "\n\n")
                            }
                            
                            ## always return the uri/code for programmatic use
                            return(invisible(list(uri = response$verification_uri,
                                                  code = response$user_code)))
                          },
                          
                          requestAccessToken = function(resource = "oauthv2/token",
                            verbose = TRUE) {
                            'Retrives and sets the access token.'

                            ## We already have a feasible access tocken
                            if((length(access_token) > 0L) && has_access()) {
                              if(verbose) cat("Access tocken already available! Run 'initializeAuth()' for a new authentication!\n")
                              return(invisible(-1L))
                            }
                              
                            ## retrieve the device_code from the current state: .self$response
                            device_code <- response$device_code
                            if(is.null(device_code)) 
                              stop("'device_code' not available in the current state!")
                            
                            ## send request for the verification code
                            res <- POSTForm(uri, resource = resource,
                                            .params = list(client_id = client_id,
                                              client_secret = client_secret,
                                              grant_type = "device",
                                              code = device_code))

                            ## save the response status
                            response_status <<- .extractStatus(res)

                            ## save the current state in the .self$response
                            response <<- res$body

                            if(!success(response_status, OK = TRUE)) {
                              warning("Failed acquiring the access token!\n",
                                      .printFail(response_status),
                                      "Use showResponse() method to print the response body.")
                              return(invisible(as.integer(Hstatus(response_status))))
                            }

                            cat(" Access token successfully acquired!\n\n")
                            access_token <<- res$body$access_token
                            
                            ## Set the curl handler to enable persistant connections
                            set_handle()
                            
                            return(invisible(1L))
                          },

                          ## Check if the available access token is feasible and can be used to query the API
                          ## We could potentially return the error codes/status ...
                          has_access = function() {
                            'Perform a GET request to the server and check if the
                             credentials are good
                            '
                            if(is.null(curl_handle))
                              set_handle()
                            
                            res <- GET(uri, curl = curl_handle, resource = "users/current")
                            ## save the response status
                            response_status <<- .extractStatus(res)

                            if(!success(response_status, OK = TRUE))
                              return(FALSE)
                            
                            return(TRUE)
                          }
                          )
                        )


## For now the GET and POST will return the R list representation of the JSON object
## At a later stage we might return a class for each type of request ... 
.AppAuth$methods(doGET = function(...) {
  'Perform a GET request to the server  
  '
  if(is.null(curl_handle))
    set_handle()
  
  res <- GET(uri, curl = curl_handle, ...)

  ## save the response status
  response_status <<- .extractStatus(res)

  if(!success(response_status, OK = TRUE)) {
    warning("GET failed!\n", .printFail(response_status),
            "Use showResponse() method to print the response body.")
    ## store the current state in the .self$response
    response <<- res$body 
    return(invisible(NULL))
  }
  
  ## we return only the Response element
  return(res$body$Response)
})
  

## doPOST will call either POSTForm or POST depending if 'postbody' is set or not 
.AppAuth$methods(doPOST = function(..., headerFields, postbody) {
  'Perform a POST request to the server'
  if(is.null(curl_handle))
    set_handle()

  ## update the header if necessary 
  h <- if(missing(headerFields)) curl_handle
  else dup_handle(headerFields)

  ## call either POST or POSTForm
  res <- if(missing(postbody))
    POSTForm(uri, curl = h, ...)
  else
    POST(uri, curl = h, postfields = postbody, ...)
  
  ## save the response status
  response_status <<- .extractStatus(res)

  ## accept any HTTP 2xx code (Success)
  if(!success(response_status)) {
    warning("POST failed!\n", .printFail(response_status),
            "Use showResponse() method to print the response body.")
    ## store the current state in the .self$response
    response <<- res$body 
    return(invisible(NULL))
  }
  
  ## we return only the Response element
  return(res$body$Response)
})


## User level function for starting the OAuth process and obtaining the access tocken
setMethod("requestAccessToken", "AppAuth", function(x, ...) x$requestAccessToken(...))
setMethod("initializeAuth", "AppAuth", function(x, ...) x$initializeAuth(...))
setMethod("hasAccess", "AppAuth", function(x) x$has_access())


## ResponseStatus interface
setMethod("Hstatus", "AppAuth", function(x) Hstatus(x$response_status))
setMethod("HstatusMessage", "AppAuth", function(x) HstatusMessage(x$response_status))
setMethod("Message", "AppAuth", function(x) Message(x$response_status))
setMethod("ErrorCode", "AppAuth", function(x) ErrorCode(x$response_status))
## do we need this?
setMethod("success", "AppAuth", function(x) success(x$response_status))


######################################################################


## Constructor - user level
## @...  parameters to pass to initializeAuth() method - we might have to change this later!
AppAuth <- function(client_id = character(), client_secret = character(),
                    access_token, uri = ServiceURI(), ..., doOAuth = TRUE) {

  ## Instance of AppAuth class
  ## We might need to do some validation on the client_id and client_secret...
  app <- .AppAuth(client_id = client_id, client_secret = client_secret, uri = uri)

  ## If the access_tocken is provided we don't need to perform OAuth protocol.
  ## Also for this to work we don't need the client_id/secrete.
  if(!missing(access_token)) {
    app$access_token <- access_token
    app$set_handle()
    
    return(app)
  } 
  
  ## initialize the OAuth process
  if(doOAuth)
    app$initializeAuth(...)
  
  return(app)
}


## High level function for starting the OAuth process
## Returns an AppAuth handler with a valid access tocken or NULL
## @...  parameters to pass to initializeAuth() method - same as for AppAuth()
performOAuth <- function(client_id = character(), client_secret = character(),
                         uri = ServiceURI(), ..., sec = 3L) {

  ## Instance of AppAuth class
  app <- .AppAuth(client_id = client_id, client_secret = client_secret, uri = uri)
  
  ## Start the OAuth process - 'scope' is provided via '...'
  ##app$initializeAuth(useBrowser = TRUE, ...)
  app$initializeAuth(...)

  ## Wait for the user to authenticate - time outs after 20 cycles ~1 min
  for(i in 1:20) {
    Sys.sleep(sec)
    if(app$requestAccessToken(verbose = FALSE) == 1L) {
      i <- 1L
      break
    }
  }
  
  ## If it timeouts we return an error
  if(i == 20) 
    stop("User has denied the access request or has not yet approved the access request.")
  
  return(app)
}



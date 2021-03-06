############################################################           
##  S e r v i c e U R I    C L A S S
############################################################           
## class that will manage the server URI
## we call methods from an objects to get the uri for the REST API ...
## AND
## probably most of the 'curl' functionality should be done at this level
## we just need to call the POST/GET with various parameters / header ....
## the RESTful API should be build using the interface provided by this class 
setClass("ServiceURI",
         representation = list(
           url = "character", 
           version = "character"))

ServiceURI <- function(url = "https://api.basespace.illumina.com",
                       version = "v1pre3") {
  new("ServiceURI", url = url, version = version)
}


setMethod("show", "ServiceURI", function(object) {
  cat("URL:     ", object@url, "\n")
  cat("Version: ", object@version, "\n")
})


## very basic for now... we can enrich this later 
setMethod("uri", "ServiceURI",
          function(x, resource = "") {
            res <- make_resource(x@url, x@version)
            if(nchar(resource) > 0L)
              res <- make_resource(res, resource)
            
            return(res)
          })


## the processing of the returned header and the body could be optimized - TODO!
## we could also introduce a switch to avoid grabing the header
## @... are parameters send to postForm.
##      Often used options: curl = handler and .params = list(<POST params>)
setMethod("POSTForm", "ServiceURI",
          function(x, resource, ..., verbose = FALSE) {
            H <- basicHeaderGatherer()
            B <- basicTextGatherer()
            postForm(uri(x, resource), style = "POST",
                     .opts = curlOptions(verbose = verbose,
                       headerfunction = H$update,
                       writefunction = B$update), ...)
            ## H <- H$value() # we could use the header to check if the content is JSON
            ##grepl("application/json", H["Content-Type"]) == TRUE !!!
            return(list(header = H$value(),
                        body = fromJSON(B$value(), simplifyWithNames = FALSE, nullValue = NA)))
          })



## @... are parameters send to curlPerform
##      Often used options: curl = handler and postfields = <JSON string>
setMethod("POST", "ServiceURI",
          function(x, resource, postfields, ..., verbose = FALSE) {
            H <- basicHeaderGatherer()
            B <- basicTextGatherer()
            curlPerform(url = uri(x, resource), postfields = postfields, 
                        headerfunction = H$update, writefunction = B$update,
                        verbose = verbose, ...)
            ## H <- H$value() # we could use the header to check if the content is JSON
            ##grepl("application/json", H["Content-Type"]) == TRUE !!!
            return(list(header = H$value(),
                        body = fromJSON(B$value(), simplifyWithNames = FALSE, nullValue = NA)))
          })


## @...     are parameters send to getForm()
##          Often used options: curl = handler
## @asJSON  Logical switch. If TRUE (default) then the output is parsed
##          from a JSON stream to an R list using fromJSON().
##          Otherwise the raw string is return as the body elemnt. 
setMethod("GET", "ServiceURI",
          function(x, resource, ..., asJSON = TRUE, verbose = FALSE) {
            H <- basicHeaderGatherer()
            B <- basicTextGatherer()
            suppressWarnings(getForm(uri(x, resource),
                                     .opts = curlOptions(verbose = verbose,
                                       headerfunction = H$update,
                                       writefunction = B$update), ...))
            ## H <- H$value() # we could use the header to check if the content is JSON
            ##grepl("application/json", H["Content-Type"]) == TRUE !!!
            body <- if(asJSON)
                fromJSON(B$value(), simplifyWithNames = FALSE, nullValue = NA)
            else
                B$value()
            
            return(list(header = H$value(), body = body))
          })



############################################################           
##  R E S T   A P I   E R R O R   M a n a g e m e n t
############################################################           

## Hstatus = {200, 400, 403, 404} # should we expect others?

setClass("ResponseStatus", 
         representation = representation(
             ## The HTTP status - from the header
             Hstatus = "character",
             ## The HTTP statusMessage - from the header
             HstatusMessage = "character",
             ## ResponseStatus Message
             Message = "character",
             ## ResponseStatus ErrorCode
             ErrorCode = "character",
             ## ResponseStatus Errors
             Errors = "ANY"),
         prototype = prototype(Hstatus = character(),
             HstatusMessage = character(),
             Message = character(),
             ErrorCode = character(),
             Errors = list()))


############################################################           
## Accessors
############################################################           

setMethod("Hstatus", "ResponseStatus", function(x) x@Hstatus)
setMethod("HstatusMessage", "ResponseStatus", function(x) x@HstatusMessage)
setMethod("Message", "ResponseStatus", function(x) x@Message)
setMethod("ErrorCode", "ResponseStatus", function(x) x@ErrorCode)



############################################################           
## Constructor
############################################################           

## @header:  the header returned by RCurl calls
ResponseStatus <- function(header, Message = character(),
                           ErrorCode = character(), Errors = list()) {

    ## we force coercion to chacracter. as.character(NULL) == character()
    res <- new("ResponseStatus", Message = as.character(Message),
               ErrorCode = as.character(ErrorCode), Errors = as.character(Errors))

    if(!missing(header)) {
        slot(res, "Hstatus", check = TRUE) <- header[["status"]]
        slot(res, "HstatusMessage", check = TRUE) <- header[["statusMessage"]]
    }

    return(res)
}

############################################################           
## Methods
############################################################           

## Returns TRUE if the Hstatus is 2xx
## @OK: Logical switch. If set to TRUE, then the function will
##      return TRUE iff Hstatus == 200.
setMethod("success", "ResponseStatus",
          function(x, OK = FALSE) {
              h <- Hstatus(x)
              if(length(h) == 0L)
                  return(FALSE)
              if(!grepl("^2[[:digit:]]{2}$", h))
                  return(FALSE)
              if(OK && h != "200")
                  return(FALSE)
              
              return(TRUE)
          })


## For in internal use -- DO NOT EXPORT!
.printFail <- function(x) {
    paste("  HTTP code:       ", x@Hstatus, " ", x@HstatusMessage, "\n",
          "  Server message:  ", x@Message, "\n", sep = "")
}


## TODO
## Simple print method.
setMethod("show", "ResponseStatus",
          function(object) {
              cat(class(object), "object:\n")
              cat("  HTTP status:      ", object@Hstatus, "\n")
              cat("  HTTP phrase:      ", object@HstatusMessage, "\n")
              cat("  Server message:   ", object@Message, "\n")
          })


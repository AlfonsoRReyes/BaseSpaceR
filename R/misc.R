## !!! Do not export !!!
## for internal use - replacement for file.path
## will work as paste(..., sep = "/")
## could be optimized such that we cannonize the resource
make_resource <- function(...)  file.path(...)

## !!! Do not export !!!
## extract the last component from the resource href
## this works only for resourse hrefs and not for listing a resourses Href*
id_from_href <- function(path) basename(path)


## Simple function to be sure that ids are not passed as numerics
## Only integers and characters are allowed, but we don't check this here ...
## !!! Do not export !!!
as_id <- function(id) { if(is.numeric(id)) as.integer(id) else id }


## Check if a numeric vector contains only integers (NA allowed)
## If all elements are integers it converts the input to an integer vector
.forceIntegers <- function(x) {
  if(is.numeric(x) && max(x, na.rm = TRUE) <= .Machine$integer.max &&
     all(abs(x - round(x)) < .Machine$double.eps^0.5, na.rm = TRUE))
    x <- as.integer(x)
  return(x)
}


## !!! Do not export !!!
## Parse the URI spliting the URI from the parameters.
## The parameters are returned as a named vector.
tokenizeURI <- function(x) {
  x <- strsplit(x, split = "?", fixed = TRUE)[[1L]]

  ## the URL - it contains the http://
  URL <- x[1L]

  ## the parameters
  x <- strsplit(strsplit(x[2L], split = "&", fixed = TRUE)[[1L]], split = "=", fixed = TRUE)
  param <- vapply(x, "[", character(1L), 2L)
  names(param) <- vapply(x, "[", character(1L), 1L)

  return(list(URL = URL, param = param))
}


################################
## Couple list utility functions

## !!! Do not export !!!
list_len <- function(x, use.names = FALSE) {
  r <- unlist(lapply(x, length), recursive = FALSE, use.names = FALSE)
  if(use.names)
    names(r) <- names(x)
  return(r)
}

## Creates a named list with the same length as 'lnames'
## !!! Do not export !!!
named_list <- function(lnames = character()) {
  l <- vector("list", length(lnames))
  names(l) <- lnames
  return(l)
}

## given a well formed "list of list" L, this function
## retuns a list L' such that L'[[i]][[j]] == L[[j]][[i]]
## we could also use the folloing syntax: L' <- t(L), and implement
## t() as a method for lists, but this function works only for a special case ... 
## !!! Do not export !!!
transpose_list <- function(x, check.names = FALSE) {
  if(length(x) == 0L)
    return(x)
  ## check that all entries have the same number of elements
  len <- list_len(x)
  if(length(unique(len)) > 1L)
    stop("All list entries must have the same number of elements")
  
  elem <- x[[1L]]
  l <- if(is.null(names(elem)))
    vector("list", length(elem))
  else named_list(names(elem))

  ## if check.names is true we use names indexing 
  iterator <- if(check.names) names(l) else seq_along(l)

  for(i in iterator)
    l[[i]] <- lapply(x, "[[", i)
  
  return(l)
}


################################
## REST API utilities

## !!! Do not export !!!
## wrapper for internal use only - assumes JSON parsing 
.extractStatus <- function(x) {

  if("ResponseStatus" %in% names(x$body)) {
    ## API resource calls
    er <- x$body$ResponseStatus
    return(ResponseStatus(header = x$header,
                          Message = er$Message, 
                          ErrorCode = er$ErrorCode,
                          Errors = er$Errors))
  }

  ## Authentication calls
  ResponseStatus(header = x$header,
                 Message = x$body$error_description, 
                 ErrorCode = x$body$error)
}
  

## !!! Do not export !!!
## for internal use - low level debug function,
## returns the (un)parsed JSON as an R list.
## @x: AppAuth instance
## @what: c("runs/1927", "projects/1", "projects/1/appresults", ...)

query <- function(x, what, ..., asJSON = TRUE) {
    if(is.null(x$curl_handle))
        x$set_handle()
    
    res <- GET(x$uri, resource = what, curl = x$curl_handle, ..., asJSON = asJSON)
    
    retVal <- res$body
    attr(retVal, "header") <- res$header
    
    return(retVal)
}


## for internal use - list the metadata for a resource and given id(s)
## @what: c("runs", "projects", "samples", ...)
## @ it retruns a list of object (or one object if simplify = TURE) of the same class as 'x'
## !!! Do not export !!!
.r2I <- c(users = "userItem", runs = "runItem", projects = "projectItem",
          samples = "sampleItem", appresults = "appResultItem",
          files = "fileItem", genomes = "genomeItem")

.queryResource <- function(x, what, id, simplify) {
  id <- as_id(id)
  res <- lapply(id, function(i) {
    obj <- x
    response <- auth(x)$doGET(resource = make_resource(what, i))
    if(is.null(response))
      return(NULL)
    obj@data <- ItemFromJList(.r2I[what], response)
    return(obj)
  })

  if(length(id) == 1L && simplify)
    return(res[[1L]])

  names(res) <- id
  return(res)
}

## .listResource <- function(x, what, id, simplify) {
##   id <- as_id(id)
##   res <- lapply(id, function(i) ItemFromJList(.r2I[what], x$doGET(resource = make_resource(what, i))))

##   if(length(id) == 1L && simplify)
##     return(res[[1L]])

##   names(res) <- id
##   return(res)
## }


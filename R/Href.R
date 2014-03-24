############################################################           
##  H r e f    C L A S S
############################################################           
##
## Class to manage the server href* entries returned by the REST API ...
##
## The Href elements found in the BaseSpace API response have the
## following structure: "<API version>/<resource endpoint>"
##
## Every response element contains an Href, the self Href,
## and the endpoints of the childern, if any.

setClass("staticHref",
         representation = list(
           ## the resource endpoint
           resource = "character",
           ## the API version
           version = "character"))

## Href extends staticHref class by adding an AppAuth handler
## This gives us the possibility to make API calls using Hrefs
setClass("Href", contains = "staticHref",
         representation = list(
           ## an AppAuth instance
           auth = "AppAuth"
           ))


############################################################           
## Accessors
############################################################           
#setMethod("resource", "staticHref", function(x) x@resource)
#setMethod("version", "staticHref", function(x) x@resource)
setMethod("auth", "Href", function(x) x@auth)

############################################################           
## Constructor
############################################################           

## Constructur from a string.
## Super simple for now, split the string in two 
staticHref <- function(x) {
  pos <- regexpr("/", x, fixed = TRUE)
  ## check if x contains at least one '/'
  if(pos < 0) {
    warning("Error parsing 'x' - not a valid Href.")
    return(new("staticHref"))
  }
  
  new("staticHref",
      ## the endpoint
      resource = substr(x, start = pos + 1L, stop = nchar(x)),
      version = substr(x, start = 1L, stop = pos - 1L))
}

  

## Href is a method - it will dispatch on various objects,
## but the nice thing is that will return a Href object.
#Href


############################################################           
## Methods
############################################################           
setMethod("as.character", "staticHref",
          function(x) make_resource(x@version, x@resource))


setMethod("show", "staticHref", function(object) {
  cat(make_resource(object@version, object@resource), "\n")
})

##setMethod("show", "Href", function(object) {
##  cat(make_resource(object@version, object@resource), "\n")
##})


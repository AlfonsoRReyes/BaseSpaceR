############################################################           
##  F I L E S  -  H I G H   L E V E L   M E T H O D S
############################################################           


## for an AppResult (or AppResulsSummary at a later stage) find all
## BAM files and return a list of (.bam, .bai) pairs
getIndexedBam <- function(appRes) {
  
  ## find all BAMS
  ##bam <- listFiles(appRes, Extensions = ".bam", Extensions = ".bai")
  bam <- listFiles(appRes, Extensions = ".bam")
  if(!length(bam))
    return(NULL)

  ## get the bam index, if exists
  bai <- listFiles(appRes, Extensions = ".bai")

  ## remove the '.bam' and '.bai' extensions
  bname <- substr(Name(bam), 1L, nchar(Name(bam)) - 4L)
  iname <- sub(".bam", "", substr(Name(bai), 1L, nchar(Name(bai)) - 4L), fixed = TRUE)

  ## the indexed bams
  idx <- match(bname, iname, 0L)
  ibam <- which(idx > 0L)
  names(ibam) <- Name(bam)[ibam]

  ## named list of (BAM_ID, BAI_ID)
  return(lapply(ibam, function(i) c(Id(bam)[i], Id(bai)[idx[i]])))
}


##
## @x:     AppAuth object
## @ibam:  A touple containing the ID of the BAM in the first position
##         followed by the ID of the .bai in the second.
## @...:"  parameters for BamFile()
##
asBamFile <- function(ibam, x, ...) {
  
  ## we do this temporary
  require(Rsamtools)
  ## make sure x store correctly formed IDs.
  ibam <- as_id(ibam)

  ## download the bam index into a temporary file
  indexLoc <- tempdir()
  res <- getFiles(x, id = ibam[2L], destDir = indexLoc, verbose = FALSE)

  ## get the URL of the BAM
  bamhref <- x$doGET(resource = make_resource("files", ibam[1L], "content"), redirect = "meta")

  ## message for how long the link is active?
  ##format(as.Date(bamhref))
  ## we can also check if the href supports range queries
  ## if(!bamhref$SupportsRange) {
  ##    warning("Selected BAM href doesn't support range queries!")
  ##    return(BamFile)
  ## }
  
  ## use the http protocol instead of https
  bamhref <- sub("https:", "http:", bamhref$HrefContent, fixed = TRUE)

  ## create a BamFile object
  BamFile(file = bamhref, index = file.path(indexLoc, res$Path), ...)
}


## Selects all appResults listed in the AppReultsSummary instance
setMethod("getBAMs", "AppResults", 
          function(x, simplify = TRUE, ...) {
            ## find all the indexed BAMs for the specified AppResults instance
            ibam <- getIndexedBam(x)
            
            ## for each indexed bam build a BamFile
            bam <- lapply(ibam, asBamFile, x  = auth(x),  ...)

            ## return a BamFileList if there are more than 2 BAM or if simplify is set to FALSE
            if (length(bam) == 1L && simplify) 
              return(bam[[1L]])
            
            return(do.call(BamFileList, bam))
          })

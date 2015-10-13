## Properties are a lightweight storage mechanism associated
## BaseSpace resources exposed via the public API.

## Several basic data types are supported: string, maps and pointers
## to other resources.


############################################################           
## Property
############################################################           

setClass("Property",
         representation = representation(
           ## Type of the Property 
           Type = "character",
           ## Name of Property - unique identifier - namespace convention
           Name = "character",
           ## Location of the resource in the API
           Href = "character",
           ## Property description
           Description = "character", 
           ## The total number of items in the collection
           ItemsTotalCount = "integer",
           ## Main container. A list of Type objects
           Items = "list"))



############################################################           
## PropertyCollection
############################################################           
## A Collection is a SimpleList with a more rich interface
## We need a special Collection type for Property since
## the elements have a different structure then Item!

setClass("PropertyCollection", ## contains = "SimpleList",
         representation = representation(
           ## Main container or the response, basically a 'list',
           ## but can be an object sharing the 'list' interface.
           Items = "list",
           ## The total number of items in the collection
           TotalCount = "integer",
           ## The starting point of the collection to read, there is no maximum value for Offset. Default: 0
           Offset = "integer",
           ## The maximum number of items to return. Range 0-1024
           Limit = "integer", 
           ## The way to sort the resulting collection, either ascending or descending. Default: 'Asc', Can be 'Asc' or 'Desc'
           SortDir = "character",
           ## The field to use to sort the resulting collection.
           SortBy = "character"),
         prototype = prototype(Items = list(), TotalCount = integer(),
           Offset = 0L, Limit = integer()))



############################################################           
## Accessors
############################################################           

####  Property   ####
## setMethod("Type", "Property", function(x) x@Type)
## setMethod("Name", "Property", function(x) x@Name)
## setMethod("Href", "Property", function(x) x@Href)
## setMethod("Description", "Property", function(x) x@Description)
## setMethod("ItemsTotalCount", "Property", function(x) x@ItemsTotalCount)
## setMethod("Content", "Property", function(x) x@Content)


## ####  PropertyCollection   ####
## setMethod("Items", "PropertyCollection", function(x) x@Items)
## setMethod("TotalCount", "PropertyCollection", function(x) x@TotalCount)
## setMethod("Offset", "PropertyCollection", function(x) x@Offset)
## setMethod("Limit", "PropertyCollection", function(x) x@Limit)
## setMethod("SortDir", "PropertyCollection", function(x) x@SortDir)
## setMethod("SortBy", "PropertyCollection", function(x) x@SortBy)


## ## A Property has the same interface as a PropertyCollection of size 1
## ## this will make it fit easier in the Response element
## setMethod("Items", "Property", function(x) x)
## setMethod("TotalCount", "Property", function(x) as.integer(NA))
## setMethod("Offset", "Property", function(x) NA)
## setMethod("Limit", "Property", function(x) as.integer(NA))
## setMethod("SortDir", "Property", function(x) NA)
## setMethod("SortBy", "Property", function(x) NA)
## setMethod("DisplayedCount", "Property", function(x) 1L)

## ## PropertyCollection also implements the Property interface
## setMethod("Type", "PropertyCollection", function(x) .selectFromItemList(x@Items, Type))
## setMethod("Name", "PropertyCollection", function(x) .selectFromItemList(x@Items, Name))
## setMethod("Href", "PropertyCollection", function(x) .selectFromItemList(x@Items, Href))
## setMethod("Description", "PropertyCollection", function(x) .selectFromItemList(x@Items, Description))
## setMethod("ItemsTotalCount", "PropertyCollection", function(x) .selectFromItemList(x@Items, ItemsTotalCount))
## ## this would be a named list [Property$Name: Property$Content]
## setMethod("Content", "PropertyCollection", function(x) .selectFromItemList(x@Items, HrefBaseSpaceUI))


## ############################################################           
## ## Constructor
## ############################################################           

## ####  Property   ####
## ## !!! Do not export !!! - for in internal use only
## ## This is quite general, and should apply for all classes inheriting
## ## from 'Property' if we decide to specialize those
## PropertyFromJList <- ItemFromJList(class = "Property", l) # we might need a different one...

  
## ####  PropertyCollection   ####
## ## !!! Do not export !!! - for in internal use only
## ## @l:  if pressent, it must be a list containing all the slots in the class
## ## @items:  if pressent is the list of Item objects.
## ##          Only the 'DisplayedCount' is updated in this case
## PropertyCollectionFromJList <- CollectionFromJList(class = "PropertyCollection", l, items) # we might need a different one...


############################################################           
## Methods
############################################################           



## asSingleton() - forces a Property containing array Items object to
##                 be serialized as a singleton Property - if possible  

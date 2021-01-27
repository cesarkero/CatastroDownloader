#' FeedProvinces
#'
#' @export FeedProvinces
#'
#' @param catastropush --> given an atom url this returns the list for Provinces names
#'
#' @description given a url feed from Spanish Catastro it returns the list of Provinces
#'
#' @return list of Provinces
#'
#' @examples
#' \dontrun{
#' FeedProvinces("http://www.catastro.minhap.es/INSPIRE/buildings/ES.SDGC.bu.atom.xml")
#' }
#-------------------------------------------------------------------------------
FeedProvinces <- function(catastropush){
    # Read catastro (level 1) (THIS COULD HAVE BEEN LEFT OUT OF THE FUNCTION)
    c1 <- feed.extract(catastropush)$items

    # list of xml (2 level link) and Provinces (THIS COULD HAVE BEEN LEFT OUT OF THE FUNCTION)
    c1link <- c1$link
    provinces  <- trimws(substring(c1$title, 23, 100))

    return(provinces)
}

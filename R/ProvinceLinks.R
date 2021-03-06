#' ProvinceLinks
#'
#' @export ProvinceLinks
#'
#' @param catastropush --> given an atom url returns a data.frame Provices|URL
#'
#' @description Given a catastropush it returns a data frame with the url .xml for each Province
#'
#' @return data frame with 2 columns (Provincia & URL)
#'
#' @examples
#' \dontrun{
#' ProvinceLinks("http://www.catastro.minhap.es/INSPIRE/buildings/ES.SDGC.bu.atom.xml")
#' }
#-------------------------------------------------------------------------------
# ProvinceLinks
# this function returns a list of provinces from catastro web
ProvinceLinks <- function(catastropush){
    # Read catastro (level 1) (THIS COULD HAVE BEEN LEFT OUT OF THE FUNCTION)
    c1 <- feed.extract(catastropush)$items

    # list of xml (2 level link) and Provinces (THIS COULD HAVE BEEN LEFT OUT OF THE FUNCTION)
    c1link <- c1$link
    provinces  <- trimws(substring(c1$title, 23, 100))

    df <- data.frame('Provincia'=provinces, 'URL'=c1link)

    return(df)
}

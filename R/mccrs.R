#' mccrs
#'
#' @export mccrs
#'
#' @param mccrs --> list of sf objects to catch the sf_crs most commomn
#'
#' @description this function is accesory of catastroprovince and serves to capture
#' the crs in st_format of the most comment st_crs within a list of spatial objects
#'
#' @return CRS in st_crs format to transform or assign others
#'
#' @examples
#' \dontrun{
#' mccrs(sflist)
#' }
#-------------------------------------------------------------------------------
mccrs <- function(sflist){
        crslist <- list()
        for(lx in 1:length(sflist)){crslist[[lx]] <- st_crs(sflist[[lx]])}
        crsunique <- unique(crslist) # capture the different crs within the municipalities

        crscount <- list() #this list stores counters of each crsunique in crslist
        for (i1 in 1:length(crsunique)){
                counter <- 0
                for (i2 in 1:length(crslist)){
                        c <- ifelse(crslist[[i2]]==crsunique[[i1]], 1, 0)
                        counter <- counter + c
                }
                crscount[[i1]] <- counter
        }

        # if there are just a max counter over the others pick that as crs
        crscountlist <- unlist(crscount)
        crsmax <- max(crscountlist)
        positionofcrsmax <- which(crsmax==crscountlist)[[1]] #if max is repeted (weird) just pick the first position
        mccrs <- crsunique[[positionofcrsmax]]
        return(mccrs)
}

#' catastrozip2st
#' @export catastrozip2st
#'
#' @param ziplink --> this is the zip url for a single municipality (captured in catastroprovince)
#' @param tempdir --> this where temporary files are stores (zips, unzips...)
#' @param name --> this is the name of the muninipality (captured in catastroprovince)
#' @param Hfloor --> asign a height of each floor above the ground (stimation of building height)
#'
#' @description
#' # catastrozip2st downloads a zip link into a temporal folder and extracts:
#'     - building.gml
#'     - buildingpart.gml
#'     - otherconstruction.gml
#'     It returns a list of 3 elements, each in st format
#'     Note1: it includes the calculation of Hmax heigth for buildingparts
#'
#' @return list of 3 elemenst (building, buildingpart, otherconstruction) in simple feature collection.
#' This parts will be merged and unified in a gpkg with the catastroprovince() function.
#'
#' @examples
#' \dontrun{
#' ziplink <- 'http://www.catastro.minhap.es/INSPIRE/Buildings/56/56101-MELILLA/A.ES.SDGC.BU.56101.zip'
#' name = 'MELILLA'
#' catastrozip2st(ziplink,tempdir,name)
#' }
catastrozip2st <- function(ziplink, tempdir = "./temp/", name, Hfloor =3){

        # set tempdir
        tempdir = paste0(tempdir,name,'/')
        ifelse(!dir.exists(tempdir),dir.create(tempdir),NA)

        tempzip <- paste0(tempdir, "temp.zip")

        # WINDOWS ERROR USING LINKS WITH Ñ --> RESOLVE
        download.file(URLencode(ziplink), destfile = tempzip, method = "auto")

        # find filename for buildingpart and building
        ns <- unzip(tempzip, list=TRUE)$Name
        bn <- ns[grepl("*building.gml", ns)]
        bpn <- ns[grepl("*buildingpart.gml", ns)]
        ocn <- ns[grepl("*construction.gml", ns)]

        # extract building, buildingpart and otherconstruction
        # the folder of extraction must be without last /
        utils::unzip(tempzip, exdir = gsub('.{1}$','',tempdir), bn)
        utils::unzip(tempzip, exdir = gsub('.{1}$','',tempdir), bpn)
        utils::unzip(tempzip, exdir = gsub('.{1}$','',tempdir), ocn)

        # read files as st (NA if .gml is not right)
        b1 <- tryCatch(st_read(paste0(tempdir, bn)), error=function(err) NA)
        b2 <- tryCatch(st_read(paste0(tempdir, bpn)), error=function(err) NA)
        b3 <- tryCatch(st_read(paste0(tempdir, ocn)), error=function(err) NA)

        #---------------------------------------------------------------------------
        # Add atributes to identify source
        #---------------------------------------------------------------------------
        # Add Hmax to buildingpart based on floors above ground (Hfloor m)
        if (!is.null(dim(b1))){b2 <- mutate(b2, Hmax = numberOfFloorsAboveGround*Hfloor)}

        #---------------------------------------------------------------------------
        # Add name if value is not NA
        l <- lapply(list(b1,b2,b3), function(x) if(!is.null(dim(x))){mutate(x, name = name)})

        #---------------------------------------------------------------------------
        # remove temporal files
        unlink(tempdir, recursive = TRUE)

        return(l)
}

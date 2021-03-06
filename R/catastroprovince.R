#' catastroprovince
#'
#' @export catastroprovince
#'
#' @param province --> is a string with the name of the provoince of interest (can be checked with FeedProvinces())
#' @param catastropush --> url of the atom service (xml url)
#' @param tempdir --> directory where temporal files are unziped and readed
#' @param output --> directory where gpkg is exported
#' @param rpush --> TRUE if you want a notification when process is over (use just if configured)
#' @param overwrite --> TRUE if you want to overwrite gpkg file in case it exist
#' @param Hfloor --> set the desired height (m) for each floor above the ground (to estimate building height)
#'
#' @description catastroprovince is a function that download all the catastro data types from
#' a list of municipalities within a province and exports the data to a gpkg. The buildings and buildingparts contain
#' both heigth estimation (based on Hfloor) and Municipality
#'
#' @return gpkgname as the directory of the gpkg file created after the process
#'
#' @examples
#' \dontrun{
#' #-------------------------------------------------------------------------------
#' # Catch Provinces Names in atom service
#' FeedProvinces(catastropush)
#'
#' # Create the list of Provinces of interest
#' provinceslist <- c("Ceuta","Melilla")
#'
#' #-------------------------------------------------------------------------------
#' # +++++++++++++++++++++ LINUX TESTS ++++++++++++++++++++++++++++++++++++++++++++
#' #-------------------------------------------------------------------------------
#' # TEST 1 --> Download Full province
#' #-------------------------------------------------------------------------------
#' catastroprovince('Ceuta', catastropush, tempfolder, output, rpush = TRUE, overwrite = FALSE)
#'
#' #---------------------------------------------------------------------------
#' # TEST 2 --> Dowload Provinces in Parallel
#' #-------------------------------------------------------------------------------
#' cl <- parallel::makeCluster(ncores, type="FORK")
#' doParallel::registerDoParallel(cl)
#'
#' foreach(i=provinceslist) %dopar% {
#'     catastroprovince(i,catastropush, tempdir, output, rpush, overwrite)}
#'
#' stopCluster(cl)
#'
#' #-------------------------------------------------------------------------------
#' # ++++++++++++++++++++++ WINDOWS TESTS +++++++++++++++++++++++++++++++++++++++++
#' #-------------------------------------------------------------------------------
#' # TEST 1 --> Download Full province
#' #-------------------------------------------------------------------------------
#' catastroprovince('Melilla',catastropush, tempfolder, output, rpush = TRUE, overwrite = TRUE)
#'
#' #---------------------------------------------------------------------------
#' # TEST 2 --> Dowload Provinces in Parallel
#' #-------------------------------------------------------------------------------
#' cl <- parallel::makeCluster(ncores, type="PSOCK")
#' doParallel::registerDoParallel(cl)
#' clusterEvalQ(cl, library("CatastroDownloader")) # load libraries
#' clusterExport(cl, c('catastropush', 'output', 'tempdir', 'ncores'))
#'
#' foreach(i=provinceslist) %dopar% {
#'     catastroprovince(i,catastropush, tempdir, output, rpush, overwrite)}
#'
#' stopCluster(cl)
#'
#' #-------------------------------------------------------------------------------
#' # ++++++++++++++++++++++ SHOW SOMETHING  +++++++++++++++++++++++++++++++++++++++++
#' #-------------------------------------------------------------------------------
#' # show some data
#' file <- paste0(output, 'Catastro_Ceuta_2021-01-26.gpkg')
#' layer <- st_read(file, 'buildingpart')
#' mapview(layer)
#' #' }
#-------------------------------------------------------------------------------
catastroprovince <- function(province = "Melilla",
                             catastropush = "http://www.catastro.minhap.es/INSPIRE/buildings/ES.SDGC.bu.atom.xml",
                             tempdir = "./temp/",
                             output = "./output/",
                             rpush = FALSE,
                             overwrite = TRUE,
                             Hfloor=3){
    # set gpkgname
    gpkgname <- paste0(output, "Catastro_", province, "_", Sys.Date(), ".gpkg")

    # Avoid processing in case overwrite = TRUE and file exists
    if (file.exists(gpkgname) & overwrite==FALSE){
        print(paste0( 'File exists and it will not be overwritten: ', gpkgname))
    } else {
        # Read catastro and get province list and links
        c <- ProvinceLinks(catastropush);    links <- c[,2];    provinces  <- c[,1]

        #---------------------------------------------------------------------------
        # set index of province in c1
        sel <- match(province, provinces)
        cat("Working on: ", provinces[sel], "\n")

        #---------------------------------------------------------------------------
        # Read catastro (level 2) for the province
        c2 <- feed.extract(links[sel])$items
        # list of dates
        c2_dates <- c2$date
        # list of links (with ñ correction)
        c2_links <- gsub("�|ï¿½",'Ñ',c2$link)
        # list of titles (corrected)
        c2_titles <- gsub("�|ï¿½",'Ñ',c2$title)
        # list of municipios_IDs
        c2_mun_IDs <- trimws(substring(c2_titles, 0, 6))
        # list of municipios (with ñ correction)
        # 1st gsub get title and remove all text before final number (ID)
        # 2nd gsub change "�" by 'Ñ'
        c2_mun <- gsub("\\s*\\w*$", "", substring(c2_titles, 8, 100))

        #---------------------------------------------------------------------------
        # create empty list to store geodata
        b1 <- list();    b2<- list();    b3 <- list()

        # Iterate over municipio and store info
        for (i in 1:dim(c2)[1]){
            cat("Downloading element ", i, " of ", dim(c2)[1], "\n")

            # Set parameters
            link <- c2_links[i]
            name <- c2_mun[i]
            id <- c2_mun_IDs[i]
            update <- c2_dates[i]

            # get geodata from zip and add province
            # here the name is captured for the municipality (useful for later filter)
            sts <- catastrozip2st(link, tempdir, name, Hfloor)

            # add st elements to lists
            b1[i] <- sts[1];    b2[i] <- sts[2];    b3[i] <- sts[3]
        }

        #---------------------------------------------------------------------------
        # remove NULL from lists
        b1c <- b1[!unlist(lapply(b1,is.null))]
        b2c <- b2[!unlist(lapply(b2,is.null))]
        b3c <- b3[!unlist(lapply(b3,is.null))]
        #---------------------------------------------------------------------------
        # before merging them all --> CRS's must be equal ¡¡¡¡
        # all CRSs must be equal --> capture the most common CRS between all files and convert the others...
        cat("\n", "Homogenize the crs to the most common one...", "\n")
        crstransform <- function (sflayer,crs) {return(tryCatch(st_transform(sflayer,crs), error=function(e) NA))}
        b1crs <- lapply(b1c, crstransform, crs = mccrs(b1c))
        b2crs <- lapply(b2c, crstransform, crs = mccrs(b2c))
        b3crs <- lapply(b3c, crstransform, crs = mccrs(b3c))
        #---------------------------------------------------------------------------
        # join each tematich list of layers (using jlayers function)
        # This part could be parallelized...
        cat("\n", "Joining layers...", "\n")
        cat("\n", "Joining buildings...", "\n")
        b1m <- do.call(rbind, b1crs)
        cat("\n", "Joining buildingparts...", "\n")
        b2m <- do.call(rbind, b2crs)
        cat("\n", "Joining otherconstructions...", "\n")
        b3m <- do.call(rbind, b3crs)
        #---------------------------------------------------------------------------
        # export layers (if NA, layer would not be written)
        cat("\n", "Exporting layers", "\n")
        # replace gpkg just in case the name are already stablished
        if (overwrite == TRUE){
            print (paste0("File exist & overwriting file: ", gpkgname))
            tryCatch(st_write(b1m, gpkgname, layer = "Building", append=FALSE))
            tryCatch(st_write(b2m, gpkgname, layer = "Buildingpart", append = TRUE))
            tryCatch(st_write(b3m, gpkgname, layer = "Otherconstruction", append = TRUE))
        } else {
            if (file.exists(gpkgname)){
                print(paste0( 'File exists and it will not be overwritten: ', gpkgname))
            } else {
                print(paste0("Writing file: ", gpkgname))
                tryCatch(st_write(b1m, gpkgname, layer = "Building", append=FALSE))
                tryCatch(st_write(b2m, gpkgname, layer = "Buildingpart", append = TRUE))
                tryCatch(st_write(b3m, gpkgname, layer = "Otherconstruction", append = TRUE))
            }
        }
    }

    #-------------------------------------------------------------------------------
    # pushbullet
    body <- paste0("Created: ", gpkgname)
    if (rpush == TRUE){pbPost("note", title="Catastro downloaded", body = body)}

    return (gpkgname)
}

% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mccrs.R
\name{mccrs}
\alias{mccrs}
\title{mccrs}
\usage{
mccrs(sflist)
}
\arguments{
\item{mccrs}{--> list of sf objects to catch the sf_crs most commomn}
}
\value{
CRS in st_crs format to transform or assign others
}
\description{
this function is accesory of catastroprovince and serves to capture
the crs in st_format of the most comment st_crs within a list of spatial objects
}
\examples{
\dontrun{
mccrs(sflist)
}
}

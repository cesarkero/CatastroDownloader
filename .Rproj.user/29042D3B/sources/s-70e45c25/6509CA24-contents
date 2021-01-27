Iterative Steiner Tree
================
2020-05-10

# Description

The goal of IterativeSteinerTree is to perform an Steiner Tree using
grass tools, in low resources pc’s with linux environments. It has been
conceived to calculate Steiner Tree in large networks without burning
out the PC. How does it work? The algorith iterates over a list of
points, creating an Steiner Tree with a sample of these. After all the
iterations, it pastes the different trees and calculates a global
Steiner Tree. This method allows the user to get rid of never used paths
and simplifies the informations the grass v.net.steiner needs. Morover,
the library contains tools to clean topology error and “undchained”
lines that can make grass crush.

# Installation

Currently, this package has been just tested just in linux because
windows configuration of R and grass is a mesh:

  - Ubuntu 20.04 with R 3.6.3
  - Windows 10 with R 4.0 + Rtools40 (some try outs but some problems
    with initGRASS(), suing osgeo4w and grass78 installed directly from
    grass)

First of all, GRASS 7.8 is needed before using these tools.

  - Windows (using osgeo4w):
    [Download](http://download.osgeo.org/osgeo4w/osgeo4w-setup-x86_64.exe)
    (Remember, not working yet in windows…)

  - Linux: the easiest way is to install it with QGIS from console:

`r sudo apt-get update && sudo apt-get install qgis qgis-plugin-grass
qgis-plugin-grass saga`

-----

Once you have grass, you can install the github version using this
lines:

``` r
update.packages()
library(devtools)
install_github("cesarkero/IterativeSteinerTree")
```

# Examples

## Clean lines (unchained lines and topology errors):

``` r
library(IterativeSteinerTree)

# basic setGRASS (based on iniGRASS params but simplified)
setGRASS(gisBase = "/usr/lib/grass78", epsg= 25829)

# Windows setGRASS example: 
# setGRASS("C:/OSGeo4W64/apps/grass/grass78", home=tempdir(), override = TRUE)

# load sldf (l) and spdf (p)
data("l"); data("p")

# clean lines
lclean <- CleanLines(l)
```

Large networks use to have little unconections and topology errors that
could result in a failure when calculating Steiner Tree. Here you can
check the differences between clean and dirty lines. Red lines are those
included in the original layer and not in the corrected one:

``` r
m1 <- mapview(l, color="red")+lclean
mapshot(m1, url = paste0(getwd(),'/man/html/m1.html')) ## create standalone .html
m1
```

<div class="figure" style="text-align: center">

<img src="./man/figures/lclean.gif" alt="Example of removed lines (red)" width="75%" />

<p class="caption">

Example of removed lines (red)

</p>

</div>

## Calculate Simple Steiner Tree

In this example we are goint to calculate a simple Steiner Tree with a
sample of 50 points, conecting those out of the network by a threshold
of 1000 m.

Use this function (remember to setGRASS/initGRASS before):

``` r
ST <- SteinerTree(lclean, p[1:50,], th = 1000)
## Warning in system2(command = command, args = arguments, stdout = outFile, :
## error in running command
```

``` r
m2 <- mapview(lclean)+ST+p[1:50,]
mapshot(m2, url = paste0(getwd(),'/man/html/m2.html')) ## create standalone .html
m2
```

<div class="figure" style="text-align: center">

<img src="./man/figures/ST.gif" alt="Example of simple Steiner Tree with 50 points" width="75%" />

<p class="caption">

Example of simple Steiner Tree with 50 points

</p>

</div>

-----

## Calculate Iterative Steiner Tree

This is the core of the library and the only tools that’s needed to
create the Steiner Tree. It can be used both to calculate a non
iterative Steiner Tree (by setting iterations = 0/1) or to calculate an
Iterative Steiner Tree. The main function will return a list of:

  - \[\[1\]\] –\> Merged Steiner Tree with all iterations
  - \[\[2\]\] –\> Total Steiner Tree calculated using Merged Steiner
    Trees and points layer
  - \[\[3\]\] –\> Total length of the Total Steiner Tree (m)
  - \[\[4\]\] –\> Total time of processing in mins

Use this function (remember to setGRASS/initGRASS
before):

``` r
IST <- IterativeSteinerTree(l = lclean, p[1:100,], th=1000, iterations = 25,
                            samples = 10, clean = FALSE, rpushbullet=TRUE)
```

In this example, an Iterative Steiner Tree have been calculated for 100
points, making 25 iterations with 10 points each:

``` r
m3 <- mapview(IST[[1]], color="blue")+IST[[2]]+p[1:100,]
mapshot(m3, url = paste0(getwd(),'/man/html/m3.html')) ## create standalone .html
m3
```

<div class="figure" style="text-align: center">

<img src="./man/figures/SST.gif" alt="Iterative Steiner Tree" width="75%" />

<p class="caption">

Iterative Steiner Tree

</p>

</div>

Moreover, if you have previously configured
[rpushbullet](https://github.com/eddelbuettel/rpushbullet) you will get
a notification in your devices when the process in
completed.

<div class="figure" style="text-align: center">

<img src="./man/figures/rpushbullet.png" alt="Example of notification" width="25%" />

<p class="caption">

Example of notification

</p>

</div>

May be is a little bit rudimentary, but it works.

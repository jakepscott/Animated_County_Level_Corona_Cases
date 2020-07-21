# Animated Coronavirus Cases/Deaths by County Function
Code for a function that generates an animated map showing new cases/deaths by county for a given state. The funciton relies on data from the New York Times Coronavirus [repo](https://github.com/nytimes/covid-19-data), and leans heavily on the [sf package](https://cran.r-project.org/web/packages/sf/index.html) for mapping. The shapefiles come from the [Census Bureau](https://www.census.gov/geographies/mapping-files/time-series/geo/carto-boundary-file.html). Population estimates also from the [Census Bureau](https://www.census.gov/data/tables/time-series/demo/popest/2010s-counties-total.html). 

## Getting Started

To get the function up and running, simply download the data and code in this repo and run the County_Animation_Function.R file. You should not have to run the Cleaning_Data.R file unless you do not have the data folder on your computer. 

### Prerequisites

To run the code on your computer you just need R and the following packages installed and loaded:

```
library(shiny)
library(tidyverse)
library(lubridate)
library(geofacet)
library(scales)
library(zoo)
library(ggtext) 
library(ggthemes)
library(shinythemes)
library(gganimate)
library(sf)
```

## Author

* **Jake Scott** - [Twitter](https://twitter.com/jakepscott2020), [Medium](https://medium.com/@jakepscott16)


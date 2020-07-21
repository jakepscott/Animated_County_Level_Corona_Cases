# Animated Coronavirus Cases/Deaths by County Function
Code for a function that generates an animated map showing new cases/deaths by county for a given state.

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


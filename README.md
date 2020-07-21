# Animated Coronavirus Cases/Deaths by County Function
I used R to build this function, which automatically generates an animated map showing new cases/deaths by county for a given state over time. Users can select the state they want to look at, the measure (cases versus deaths), the start and end date for the animation, and how wide the window for the rolling average should be. The purpose of this function is to allow myself and others to quickly get a view of the evolution of the virus over time on the county-level. 

![image](https://user-images.githubusercontent.com/56490913/88092005-d1c58000-cb5d-11ea-8bab-d5ff355b801a.png)


## Getting Started

To get the function up and running, simply download the data and code in this repo and run the County_Animation_Function.R file. You should not have to run the Cleaning_Data.R file unless you do not have the data folder on your computer. 

Once you have the function in your local environment, just run `county_animation()` to generate the animation. As mentioned above, you can adjust parameters in the function, including the state, measure, date range, and rolling average window. 

### Prerequisites

To run the code on your computer you just need R and the following packages installed and loaded:

```
library(tidyverse)
library(lubridate)
library(scales)
library(zoo)
library(gganimate)
library(sf)
```

### Data Sets and Notable Packages
The function relies on data from the New York Times Coronavirus [repo](https://github.com/nytimes/covid-19-data), and leans heavily on the [sf package](https://cran.r-project.org/web/packages/sf/index.html) for mapping. The shapefiles come from the [Census Bureau](https://www.census.gov/geographies/mapping-files/time-series/geo/carto-boundary-file.html), as do the [population estimates](https://www.census.gov/data/tables/time-series/demo/popest/2010s-counties-total.html). 

## Author

* **Jake Scott** - [Twitter](https://twitter.com/jakepscott2020), [Medium](https://medium.com/@jakepscott16)


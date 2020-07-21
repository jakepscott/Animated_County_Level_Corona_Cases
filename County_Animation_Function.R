library(tidyverse)
library(lubridate)
library(scales)
library(zoo)
library(gganimate)
library(sf)

county_animation <- function(state="Alabama", start="2020-01-20",end=Sys.Date()-1,
                             measure="New Cases Per 100k",rollmean=7) 
  {
  

# Making Sure Arguments to Function Work ----------------------------------
  if(!(measure %in% c("New Cases Per 100k", "New Deaths Per 100k"))){
    return("Method must be either 'New Cases Per 100k' or 'New Deaths Per 100k'")
  }

# Setting Parameters ------------------------------------------------------
  # Loading In Raw Data -----------------------------------------------------
  cat("Loading Data")
  US_Data <- read_csv(url("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv")) 
  county_pop_clean <- read_rds("data/county_pop_clean.RDS")
  state_pop_clean <- read_rds("data/state_pop_clean.RDS")
  US_Data <- left_join(US_Data,state_pop_clean,by="state")
  US_Data <- left_join(US_Data,county_pop_clean, by=c("state","county"))
  
  US_Data <- US_Data %>% 
    rename("State"=state,"County"=county,"Date"=date, "Cases"=cases,"Deaths"=deaths) %>% 
    filter(State==state, County!="Unknown", !is.na(fips))
  
  State_abbs <- tibble(abb=state.abb,State=state.name)
  
  US_Data <- left_join(US_Data,State_abbs)
  
  US_Data <- US_Data %>% mutate(County_Population=ifelse(County=="New York City",8399000,County_Population))
 
  county_map <- read_sf("data/cb_2018_us_county_5m/cb_2018_us_county_5m.shp") %>% 
    rename("County"=NAME,"fips"=GEOID) %>% 
    filter(fips %in% US_Data$fips)
  state_map <- read_sf("data/cb_2018_us_state_5m/cb_2018_us_state_5m.shp") %>% 
    rename("State"=NAME) %>% 
    filter(State == state)
  windowsFonts(`Roboto Condensed` = windowsFont("Roboto Condensed"))
  # Getting Dates -----------------------------------------------------------
  cat("Getting Dates")
  ##Getting the dates to look at, I do March 25 as the start because that is when all the states 
  ##have at least one case and thus show up
  latest_date <- last(US_Data$Date)
  number_of_days <- ymd(latest_date) - ymd("2020-03-25")
  
  
  
  dates <- vector(mode = "character", length = number_of_days)
  for (i in 1:number_of_days) {
    dates[i] <- as.character(ymd(latest_date) - i)
  }
  
  dates <- as_tibble(dates)
  
  
  # Prepping Data -------------------------------------------------------------
  cat(" Prepping Data")
  ####Cases per million by state####
  US_Grouped <- US_Data %>%
    arrange(Date) %>%
    group_by(Date, fips) %>%
    dplyr::summarise(Cases=sum(Cases),
                     Deaths=sum(Deaths),
                     abb=last(abb),
                     Population=last(County_Population)) %>% 
    ungroup() %>%
    arrange(Date, fips) %>% 
    mutate(cases_per_100k=(Cases/Population)*100000,
           deaths_per_100k=(Deaths/Population)*100000)
  
  
  ####Getting a Rolling Average of New Cases####
  US_Grouped <- US_Grouped %>%
    group_by(fips) %>%
    mutate(New_Cases=Cases-lag(Cases), ##New cases is today's cases minus yesterdays
           New_Cases_Avg=rollmean(New_Cases,k = rollmean,fill = NA, align = "right"),
           New_Deaths=Deaths-lag(Deaths), ##New cases is today's cases minus yesterdays
           New_Deaths_Avg=rollmean(New_Deaths,k = rollmean,fill = NA, align = "right")) %>% # this just gets a 7 day rolling average
    ungroup() %>%
    mutate(New_Cases_Per_100k=(New_Cases/Population)*100000,
           New_Deaths_Per_100k=(New_Deaths/Population)*100000,
           New_Cases_Per_100k_Avg=(New_Cases_Avg/Population)*100000,
           New_Deaths_Per_100k_Avg=(New_Deaths_Avg/Population)*100000) 
  
  ####Combining the grouped data with the map data####
  Mappable_Data <-left_join(US_Grouped,county_map, by=c("fips"))
  
  Mappable_Data <- st_as_sf(Mappable_Data) %>% filter(Date>=start & Date<end) %>% filter(!is.na(Date))
  
  ####Plotting####
  if (measure=="New Cases Per 100k") {
    plot <- ggplot(Mappable_Data) + 
      geom_sf(data=state_map, fill="grey50") +
      geom_sf(aes(fill=New_Deaths_Per_100k_Avg), color=NA) +
      geom_sf(data=county_map,fill=NA, color="black") +  
      scale_x_continuous(expand = c(0,0)) +
      scale_y_continuous(expand = c(0,0)) +
      scale_fill_viridis_c(option = "plasma", labels = comma) +
      labs(y=NULL,
           x=NULL,
           fill="New Cases Per\n100,000 Residents",
           title="New Cases By County on {frame_time}",
           caption = "Plot: @jakepscott2020 | Data: New York Times",
           subtitle = paste(rollmean, "day rolling average")) +
      theme_minimal(base_family = "Roboto Condensed", base_size = 16) +
      theme(panel.grid = element_blank(),
            plot.title = element_text(size = rel(1.2)),
            plot.subtitle = element_text(face = "plain", size = rel(1), color = "grey70"),
            plot.caption = element_text(face = "italic", size = rel(0.8), 
                                        color = "grey70"),
            legend.title = element_text(face="bold",size = rel(.8)),
            legend.text = element_text(size=rel(.7)),
            axis.text.x = element_blank(),
            axis.text.y = element_blank(),
            plot.title.position = "plot") +
      transition_time(Date)} else {
        if(measure=="New Deaths Per 100k"){
        plot <- ggplot(Mappable_Data) + 
          geom_sf(data=state_map, fill="grey50") +
          geom_sf(aes(fill=New_Deaths_Per_100k_Avg), color=NA) +
          geom_sf(data=county_map,fill=NA, color="black") +  
          scale_x_continuous(expand = c(0,0)) +
          scale_y_continuous(expand = c(0,0)) +
          scale_fill_viridis_c(option = "plasma", labels = comma) +
          labs(y=NULL,
               x=NULL,
               fill="New Deaths Per\n100,000 Residents",
               fill="New Deaths Per\n100,000 Residents",
               title="New Deaths By County on {frame_time}",
               caption = "Plot: @jakepscott2020 | Data: New York Times",
               subtitle = paste(rollmean, "day rolling average")) +
          theme_minimal(base_family = "Roboto Condensed", base_size = 16) +
          theme(panel.grid = element_blank(),
                plot.title = element_text(size = rel(1.2)),
                plot.subtitle = element_text(face = "plain", size = rel(1), color = "grey70"),
                plot.caption = element_text(face = "italic", size = rel(0.8), 
                                            color = "grey70"),
                legend.title = element_text(face="bold",size = rel(.8)),
                legend.text = element_text(size=rel(.7)),
                axis.text.x = element_blank(),
                axis.text.y = element_blank(),
                plot.title.position = "plot") +
          transition_time(Date)}}
      
  
  ####Animating####
  cat("Animating")
  gif <- animate(plot, renderer = gifski_renderer(), 
                 nframes=length(unique(Mappable_Data$Date)),
                 fps = 7,
                 end_pause = 5,
                 width = 500, 
                 height = 500)  
  gif  
}
county_animation(state = "New York", start = "2020-07-01")

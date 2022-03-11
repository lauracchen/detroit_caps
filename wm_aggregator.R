#this takes a csv with geocoded addresses and aggregates points to census tract and block groups

#set working directory and get data
setwd("C:/Users/laura/Desktop/wayne_metro_testing")
geocoded <- read.csv("AddressesUnique.csv")

#require libraries
require("tidyverse")
require("tidycensus")
require("tools")
require("dplyr")
require("stringr") 
require("data.table")
require("plyr")
require('sf')
require("tidyr")
library("readxl")
options(tigris_use_cache = TRUE) #this caches the ACS geometry

#convert to sf, assign lat and lon, coordinate reference
caps<-st_as_sf(geocoded, coords=c("lon", "lat"), crs=4326)

#Downloading census data with tidy census
#connect with census API
census_api_key("d463ce221e5a0730da51aa1e4200ec68d7ee6c81", install = TRUE, overwrite = TRUE)

variables <- load_variables(2019, 'acs5', cache = TRUE)
#View(variables)

my_var <- c(total_houses = "B11001_001",
            family_house = "B11001_002",
            nonfamily_house = "B11001_007")
#get variables at tract level in king county WA in 2019 with geometry
bg_data_19 <- get_acs(
  geography = "block group",
  county = "King",
  year = 2019,
  state = "WA",
  variables = my_var,
  survey='acs5',
  geometry=TRUE
)
head(bg_data_19)

#separate table so that pivot will work
bg_data_19_var <- bg_data_19 %>% dplyr::select(c("GEOID", "variable","estimate", "geometry"))
bg_data_19_geom <- bg_data_19 %>% dplyr::select(c("GEOID", "geometry"))

#pivot and group
bg_data_19_var <- bg_data_19_var %>%
  group_by(GEOID, variable) %>%
  st_set_geometry(NULL) %>%
  pivot_wider(id_cols = GEOID,
              names_from = variable,
              values_from = estimate, 
              values_fill = list(estimate = 0))

#merge pivoted table with geometry
bg_data_19_merge <- merge(bg_data_19_var, bg_data_19_geom) 

#may need to transform coordinate system

require(sf)
caps<-st_as_sf(shutoffs_sinfam, coords=c("lon", "lat"), crs=4326)

#Total number of shutoffs across all years
bg_data_19_merge$caps<-lengths(st_intersects(tract_data_19_merge, caps) )

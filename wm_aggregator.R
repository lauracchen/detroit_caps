#this takes a csv with geocoded addresses (lon and lat columns) and aggregates points to census tract and block groups

#set working directory and get data
setwd("C:/Users/laura/Desktop/wayne_metro_testing")
geocoded <- read.csv("HeadersDemo.csv")
#remove NAs based on latitude
geocoded <- geocoded[!is.na(geocoded$Latitude),]

#require libraries
require("tidyverse")
require("tidycensus")
require("tools")
require("dplyr")
require("stringr") 
require("data.table")
require("plyr")
require("sf")
require("tidyr")
library("readxl")
options(tigris_use_cache = TRUE) #this caches the ACS geometry

#convert to sf, assign lat and lon, coordinate reference
geocoded$Latitude <- as.numeric(geocoded$Latitude)
geocoded$Longitude <- as.numeric(geocoded$Longitude)
caps<- st_as_sf(geocoded, coords=c("Longitude", "Latitude"), crs=4326)

#Downloading census data with tidy census
#connect with census API
census_api_key("d463ce221e5a0730da51aa1e4200ec68d7ee6c81", install = TRUE, overwrite = TRUE)

variables <- load_variables(2019, 'acs5', cache = TRUE)
#View(variables)

my_var <- c(total_houses = "B11001_001",
            family_house = "B11001_002",
            nonfamily_house = "B11001_007")
#get variables at block group level in king county WA in 2019 with geometry
bg_data_19 <- get_acs(
  geography = "block group",
  county = "King",
  year = 2019,
  state = "WA",
  variables = my_var,
  survey='acs5',
  geometry=TRUE
)

#separate table so that pivot will work
bg_data_19_var <- bg_data_19 %>% dplyr::select(c("GEOID", "variable","estimate", "geometry"))
bg_data_19_geom <- unique(bg_data_19 %>% dplyr::select(c("GEOID", "geometry")))

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
class(bg_data_19_merge)

#assign geometry to data, convert to sf object
bg_data_19_merge <- st_set_geometry(bg_data_19_merge, 'geometry') %>% st_transform(4326)  

#find corresponding block group + assign GEOID of block group to account
locations <- st_intersects(caps,bg_data_19_merge)

for (x in 1:nrow(caps)) {
  print(x)
  caps$bg[x] <- bg_data_19_merge[locations[[x]],1]$GEOID
  bg_data_19_merge[locations[[i]],1]$GEOID
}

#remove identifying columns
redacted_accts <- st_drop_geometry(caps %>% select(
  !Physical.Address.1
  &!Physical.Address.2
  &!Physical.City
  &!Physical.State
  &!Physical.Zip
  &!First.Name
  &!Last.Name
  &!Home.Phone..
  &!Cell.Phone..))

#create csv file with assigned block groups
write.csv(redacted_accts, file = "CAPAccountsRedacted.csv")

#change county
#finish readme
#add tract by importing census data and then running intersect
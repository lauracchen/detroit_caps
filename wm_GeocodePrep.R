#adapted from "Seattle Shutoffs - prep for geocoding" by Winn Costantini

#title: wm_geocode_prep.R
#author: Laura Chen
#date: 3/10/22
#output: "csv file AddressesUnique.csv"

#this script takes an input xlsx with separated "Address", "City", and "Zip" and outputs a csv file containing only unique addresses.

#set the correct working directory
setwd("C:/Users/laura/Desktop/wayne_metro_testing")
library(data.table)
library(readxl)

##read in data, ensure file is in same folder as working directory
caps<- read_excel("caps_data.xlsx")
head(caps)

#transform to data table, remove duplicate rows by ADDRESS column
dt <- data.table(caps)

#remove duplicate rows
capsUnique <- dt[!duplicated(dt[ , c("Physical Address 1")]), ]

#print top of data written to csv
head(capsUnique)

#save unique rows with count column as csv
write.csv(capsUnique, file = "AddressesUnique.csv")

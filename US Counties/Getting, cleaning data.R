library(tidyverse)
# Importing census bureau data ----
co.est2019.alldata <- read.csv("E:/QGIS/Data/US Census Bureau/co-est2019-alldata.csv")

#Getting long and lat data ----
library(maps)
library(ggmap)
library(mapdata)

counties <- map_data("county")
FL_counties <- subset(counties, region == "florida")

# Merging long and lat from "counties" df to census bureau df















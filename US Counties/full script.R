library(rgdal)

# importing US Census Bureau shapefile and population data
shapefiledata <- readOGR(dsn = "E:\\QGIS\\Data\\US Census Bureau\\cb_2019_us_county_500k", 
                         layer = "cb_2019_us_county_500k")

co.est2019.alldata <- read.csv("E:/QGIS/Data/US Census Bureau/co-est2019-alldata.csv")

# Shapefile and US census data cleaning ----
shapefiledata$NAME

#getting rid of 'county' in census data

co.est2019.alldata$CTYNAME <- str_remove_all(co.est2019.alldata$CTYNAME, pattern = " County")

#removing 'city' from ones that end in city in census data

co.est2019.alldata$CTYNAME <- str_remove_all(co.est2019.alldata$CTYNAME, pattern = " city")

#remove rows that are just the states from the census data

co.est2019.alldata <- co.est2019.alldata[-which(co.est2019.alldata$COUNTY==0),]

# remove puerto rico from shapefile and census

shapefile_df <- as.data.frame(shapefiledata) #creating a df to further see data

shapefile_df <- shapefile_df[shapefile_df$STATEFP !=72,]

# remove 'parish' from Lousiana census data

co.est2019.alldata$CTYNAME <- str_remove_all(co.est2019.alldata$CTYNAME, pattern = " Parish")

# remove 'Borough' and "Census Area' from census data

co.est2019.alldata$CTYNAME <- str_remove_all(co.est2019.alldata$CTYNAME, pattern = " Census Area")
co.est2019.alldata$CTYNAME <- str_remove_all(co.est2019.alldata$CTYNAME, pattern = " Borough")

# remove 'municipality' from cenus data
co.est2019.alldata$CTYNAME <- str_remove_all(co.est2019.alldata$CTYNAME, pattern = " Municipality")

# renaming random ones from census data to match shape file

co.est2019.alldata$CTYNAME[co.est2019.alldata$CTYNAME == "Juneau City and"] <- "Juneau"
co.est2019.alldata$CTYNAME[co.est2019.alldata$CTYNAME == "Sitka City and"] <- "Sitka"
co.est2019.alldata$CTYNAME[co.est2019.alldata$CTYNAME == "Wrangell City and"] <- "Wrangell"
co.est2019.alldata$CTYNAME[co.est2019.alldata$CTYNAME == "Yakutat City and"] <- "Yakutat"

shapefile_df$NAME[shapefile_df$NAME=="DoÃ±a Ana"] <- "Doña Ana"

#removing random ones from shapefile

which(!shapefile_df$NAME %in% co.est2019.alldata$CTYNAME)

shapefile_df <- shapefile_df[which(shapefile_df$NAME %in% co.est2019.alldata$CTYNAME),]


# joining shapefile_df to census data by "county_name" and "STATEFP" ----
library(tidyverse)

colnames(shapefile_df)[6] <- "county_name"
colnames(co.est2019.alldata)[7] <- "county_name"
colnames(co.est2019.alldata)[4] <- "STATEFP"

shapefile_df$STATEFP <- as.integer(shapefile_df$STATEFP)

merged_county_data <- inner_join(shapefile_df, co.est2019.alldata, 
                                 by = c("county_name","STATEFP"))


# writing merged data to csv
write.csv(merged_county_data, file = "merged_us_counties.csv")

# I have a clean .csv file now and I'm going to join in with a geojson file I have in QGIS. After joining, I'll save a copy and export it.

# importing geojson file I made----

# the file is in my wd
us_counties_json <- readOGR("us_counties.geojson")

# using leaflet to map
library(leaflet)

pal <- colorNumeric(
  palette = "Blues",
  domain = us_counties_json$merged_us_counties_POPESTIMATE2019,
  reverse = TRUE)


options(viewer = NULL)
leaflet(us_counties_json) %>%
  setView(-93.65, 42.0285, zoom = 4) %>%
  addTiles() %>%
  addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
              fillColor = ~pal(us_counties_json$merged_us_counties_POPESTIMATE2019)) %>%
  addLegend(position = "bottomleft", pal = pal, 
            values = ~na.omit(us_counties_json$merged_us_counties_POPESTIMATE2019),
            title = "2019 Population Estimates")

# creating the table for the dashboard

table_data <- merged_county_data
table_data <- table_data[,c(6,14,26,36)]

colnames(table_data)[1] <- "County"
colnames(table_data)[2] <- "State"
colnames(table_data)[3] <- "2019 Population"
colnames(table_data)[4] <- "YoY Change"

table_data$`2019 Population` <-  formatC(table_data$`2019 Population`,format="f", big.mark=",", digits=0)

# getting duplicate counties and states - some appear more than once

n_occur <- data.frame(table(table_data$County, table_data$State))
n_occur[n_occur$Freq > 1,]

which(table_data$County == "Baltimore")
which(table_data$County == "St. Louis")
which(table_data$County == "Fairfax")
which(table_data$County == "Franklin" & table_data$State == "Virginia")
which(table_data$County == "Richmond" & table_data$State == "Virginia")
which(table_data$County == "Roanoke" & table_data$State == "Virginia")

# removing the rows
which(table_data$County == "Baltimore")
table_data <- table_data[-c(295,1640,1639,645,2137,2136,488,
                            1012,1011,583,2070,2071,977,2138,2139,
                            1347,2322,2323),]
table_data <- table_data %>%
  arrange(State, County)

library(leaflet)
library(rgeos)
library(sf)
library(rgdal)

# bringing in a shape ----
require(sf)
shapefiledata <- read_sf(dsn = ".", layer = "cb_2019_us_county_500k")


require(rgdal)
shapefiledata <- readOGR(dsn = ".", layer = "cb_2019_us_county_500k")

# THIS WORKED!
shapefiledata <- readOGR(dsn = "E:\\QGIS\\Data\\US Census Bureau\\cb_2019_us_county_500k", 
                         layer = "cb_2019_us_county_500k")



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

# seeing ones that are different from each other

setdiff(co.est2019.alldata$CTYNAME, shapefile_df$NAME) #these are in first, but not second
remove_1 <- setdiff(co.est2019.alldata$CTYNAME, shapefile_df$NAME)

setdiff(shapefile_df$NAME, co.est2019.alldata$CTYNAME) #these are in first, but not second
remove_2 <- setdiff(shapefile_df$NAME, co.est2019.alldata$CTYNAME)

#removing random ones from shapefile

which(!shapefile_df$NAME %in% co.est2019.alldata$CTYNAME)

shapefile_df <- shapefile_df[which(shapefile_df$NAME %in% co.est2019.alldata$CTYNAME),]


# joining shapefile_df to census data by "county_name" and "STATEFP"

colnames(shapefile_df)[6] <- "county_name"
colnames(co.est2019.alldata)[7] <- "county_name"
colnames(co.est2019.alldata)[4] <- "STATEFP"

shapefile_df$STATEFP <- as.integer(shapefile_df$STATEFP)

merged_county_data <- inner_join(shapefile_df, co.est2019.alldata, 
                                 by = c("county_name","STATEFP"))


# writing merged data to csv
write.csv(merged_county_data, file = "merged_us_counties.csv")

# trying to convert the merged_county df to geojson ----

library(geojsonio)

#subsetting data I need - I only want 2019 pop estimates and change yoy
merged_county_data_copy <- merged_county_data[,c(1:14,26,36)]

#getting the long and lat for each county
library(mapdata)
counties <- map_data("county")
counties <- counties[,c(1:2, 5:6)]

#I'll need to join the two by State Name and County - I'll match the counties df to the merged_counties_df
colnames(counties)[3] <- "STNAME"
colnames(counties)[4] <- "county_name"

#capitalize counties df STNANE and county_name
library(stringi)
counties$STNAME <-  stri_trans_totitle(counties$STNAME)
counties$county_name <- stri_trans_totitle(counties$county_name)

# Joininng the two
merged_county_data_copy_2 <- inner_join(counties, merged_county_data_copy, by = c("county_name", "STNAME"))



#converting to geojson - this also took too long
library(geojsonio)
merged_county_data_geojson <- geojson_json(merged_county_data_copy_2,
                                           lat = merged_county_data_copy_2$lat,
                                           lon = merged_county_data_copy_2$long,
                                           group = merged_county_data_copy_2$county_name)


# leaflet ----
pal <- colorNumeric("viridis", NULL)


#this is taking to long, I think I need to convert to a geojson
options(viewer = NULL)
leaflet(merged_county_data_copy_2) %>%
  setView(-93.65, 42.0285, zoom = 4) %>%
  addTiles() %>%
  addPolygons(lng = merged_county_data_copy_2$long, lat = merged_county_data_copy_2$lat,
              fillColor = ~pal(log10(merged_county_data_copy_2$POPESTIMATE2018)),
              smoothFactor = .2)
  

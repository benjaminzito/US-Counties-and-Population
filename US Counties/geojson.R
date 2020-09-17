library(leaflet)
library(rgdal)

us_counties_json <- readOGR(dsn ="E:\\QGIS\\Projects\\Florida\\US Counties",
                              layer = "us_counties.geojson")

# this worked - i put the file in my wd
us_counties_json <- readOGR("us_counties.geojson")

# i need to increase my memory_limit !!!
memory.limit()
memory.size(max = 8192)

#leaflet ----
pal <- colorNumeric("viridis", NULL)


# this worked!!!
options(viewer = NULL)
leaflet(us_counties_json) %>%
  setView(-93.65, 42.0285, zoom = 4) %>%
  addTiles() %>%
  addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
              fillColor = ~pal(log10(us_counties_json$merged_us_counties_POPESTIMATE2019))) %>%
  addLegend(position = "bottomleft", pal = pal, 
            values = ~na.omit(us_counties_json$merged_us_counties_POPESTIMATE2019),
            title = "2019 Population Estimates")








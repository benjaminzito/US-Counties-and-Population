# US Counties and Population
I've been trying to improve my mapping skills and I thought it would be cool to make a map showing the population of each county in the U.S.

I used two files from the U.S. Census Bureau: 
1) A shape file with the cartographic boundaries: https://www.census.gov/geographies/mapping-files/time-series/geo/carto-boundary-file.html
2) Population data: https://www.census.gov/data/datasets/time-series/demo/popest/2010s-counties-total.html#par_textimage_70769902


Steps to make the map:
1) Imported both of the files into R, changed the shapefile to a dataframe
2) Cleaned the data for both then merged the two together by the County and State
3) Exported the file into a .csv so I could import it back into QGIS
4) Joined the original shapefile with the newly created .csv into a GeoJSON
5) Mapped the GeoJSON in QGIS
6) Imported the GeoJSON into R and made a flexdashboard with a map using leaflet


![US Counties Pops](https://user-images.githubusercontent.com/51300485/93540601-30229b00-f922-11ea-9f83-84df6fac3918.png)

*Note that this map was made in QGIS. My flexdashboard can be found here: https://rpubs.com/benjaminzito

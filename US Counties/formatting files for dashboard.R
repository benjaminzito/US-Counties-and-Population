#formatting dashboard

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


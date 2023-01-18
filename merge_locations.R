library(readr)
library(dplyr)
library(this.path)
library(sf)

# Read locations
setwd(this.dir())
setwd('../DHZW_locations/location_folders/home/data')
df_homes <- read.csv('df_households_locations.csv')
colnames(df_homes)
df_homes <- df_homes %>%
  select("PC6", "PC4", "longitude", "latitude", "type", "lid")

setwd(this.dir())
setwd('../DHZW_locations/location_folders/work/data')
df_work <- read.csv('work_DHZW.csv')
colnames(df_work)

setwd(this.dir())
setwd('../DHZW_locations/location_folders/schools/data')
df_schools <- as.data.frame(st_read('schools_DHZW'))
df_schools <- df_schools %>%
  select(PC6, PC4, longitude, latitude, type, lid)
colnames(df_schools)

setwd(this.dir())
setwd('../DHZW_locations/location_folders/shopping/data')
df_shoppings <- read.csv('shopping_DHZW.csv')
colnames(df_shoppings)

setwd(this.dir())
setwd('../DHZW_locations/location_folders/sport/data')
df_sport <- read.csv('sport_DHZW.csv')
colnames(df_sport)

df_locations <- rbind(df_homes,
                      df_work,
                      df_schools,
                      df_shoppings,
                      df_sport)

setwd(this.dir())
setwd('data')
write.csv(df_locations, 'locations.csv', row.names = FALSE)
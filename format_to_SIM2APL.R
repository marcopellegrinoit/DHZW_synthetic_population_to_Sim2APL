library(readr)
library(this)

setwd(this.dir())
setwd('../DHZW_synthetic-population/output/synthetic-population-households/4_car_2022-12-26_15-50')
df_synthetic_population <- read.csv('synthetic_population_DHZW_2019.csv')
df_synthetic_population <- df_synthetic_population %>%
  rename(pid = agent_ID)
df_synthetic_population$pid <- as.numeric(gsub("[^0-9.-]", "", df_synthetic_population$pid))

setwd(this.dir())
setwd('../DHZW_locations/location_folders/home/data')
df_households <- read.csv('df_households_coordinates.csv')
df_households$PC4 <-gsub('.{2}$', '', df_households$PC6)

setwd(this.dir())
setwd('data')
df_activities <- read.csv('SIM2APL_activities.csv')
df_activities <- df_activities %>%
  rename(pid = agent_ID)
df_activities$pid <- as.numeric(gsub("[^0-9.-]", "", df_activities$pid))

setwd(this.dir())
setwd('output')
write.csv(df_synthetic_population, 'DHZW_synthetic_population.csv', row.names = FALSE, quote=FALSE)
write.csv(df_households, 'DHZW_households.csv', row.names = FALSE, quote=FALSE)
write.csv(df_activities, 'DHZW_activities_locations.csv', row.names = FALSE, quote=FALSE)
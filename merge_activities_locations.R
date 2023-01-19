library(readr)
library(dplyr)
library(this.path)

# Read activities
setwd(this.dir())
setwd('../DHZW_assign_locations/data')
df_activities <- read.csv('df_synthetic_activities.csv')
df_activities <- subset(df_activities, select=-c(PC4))

# Read locations
setwd(this.dir())
setwd('data')
df_locations <- read.csv('locations.csv')

df_activities_merged <- left_join(df_activities, df_locations, by='lid')

df_activities_merged[df_activities_merged$lid == 'outside DHZW',]$lid <- 'outside_DHZW'
df_activities_merged[df_activities_merged$lid == 'outside_DHZW',]$PC6 <- 'NA'
df_activities_merged[df_activities_merged$lid == 'outside_DHZW',]$PC4 <- 'NA'
df_activities_merged[df_activities_merged$lid == 'outside_DHZW',]$longitude <- 0.0
df_activities_merged[df_activities_merged$lid == 'outside_DHZW',]$latitude <- 0.0

df_activities_merged <- subset(df_activities_merged, select=-c(type))

# 1 day
df_activities_merged <- df_activities_merged[df_activities_merged$day_of_week==1,]

write.csv(df_activities_merged, 'SIM2APL_activities.csv', row.names = FALSE)
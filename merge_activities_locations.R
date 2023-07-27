library(readr)
library(dplyr)
library(this.path)

# Read activities
setwd(this.dir())
setwd('../DHZW_assign_locations/data')
df_activities <- read.csv('df_synthetic_activities.csv')

# check
nrow(df_activities[df_activities$activity_type=='sport' & is.na(df_activities$lid),])
nrow(df_activities[df_activities$activity_type=='home' & is.na(df_activities$lid),])
nrow(df_activities[df_activities$activity_type=='work' & is.na(df_activities$lid),])
nrow(df_activities[df_activities$activity_type=='school' & is.na(df_activities$lid),])

################################################################################
# Real locations

# Read locations
setwd(this.dir())
setwd('../DHZW_locations/data/output')
df_locations <- read.csv('locations_merged.csv')
df_locations <- df_locations %>%
  rename(real_coordinate_y = coordinate_y,
         real_coordinate_x = coordinate_x)

df_activities_inside <- df_activities[df_activities$in_DHZW==1,]

nrow(df_activities_inside)
df_activities_inside <- left_join(df_activities_inside, df_locations, by='lid')
nrow(df_activities_inside)

################################################################################
# Locations outside: PC4 centroids

# Read PC4 centroids
setwd(this.dir())
setwd('../DHZW_shapefiles/data/processed/csv/')
df_PC4_NL_centroids <- read.csv('centroids_PC4_NL.csv')

df_PC4_NL_centroids <- df_PC4_NL_centroids %>%
  rename(PC4_coordinate_y = coordinate_y,
         PC4_coordinate_x = coordinate_x)

df_activities_outside <- df_activities[df_activities$in_DHZW==0,]

nrow(df_activities_outside)
df_activities_outside <- merge(df_activities_outside, df_PC4_NL_centroids, by.x='lid', by.y='PC4')
nrow(df_activities_outside)

nrow(df_activities_inside)
df_activities_inside <- merge(df_activities_inside, df_PC4_NL_centroids, by.x='PC4', by.y='PC4')
nrow(df_activities_inside)

df_activities_outside$PC4 <- df_activities_outside$lid
df_activities_outside$PC6 <- NA
df_activities_outside$real_coordinate_y <- NA
df_activities_outside$real_coordinate_x <- NA

################################################################################
# Merge together

df_activities <- rbind(df_activities_inside, df_activities_outside)

################################################################################
# PC5 centroids

# Read PC5 centroids
setwd(this.dir())
setwd('../DHZW_shapefiles/data/processed/csv/')
df_PC5_NL_centroids <- read.csv('centroids_PC5_NL.csv')

df_PC5_NL_centroids <- df_PC5_NL_centroids %>%
  rename(PC5_coordinate_y = coordinate_y,
         PC5_coordinate_x = coordinate_x)

df_activities$PC5 <- gsub('.{1}$', '', df_activities$PC6)

nrow(df_activities)
df_activities <- left_join(df_activities, df_PC5_NL_centroids, by='PC5')
nrow(df_activities)

################################################################################
# PC6 centroids

# Read PC4 centroids
setwd(this.dir())
setwd('../DHZW_shapefiles/data/processed/csv/')
df_PC6_NL_centroids <- read.csv('centroids_PC6_NL.csv')

df_PC6_NL_centroids <- df_PC6_NL_centroids %>%
  rename(PC6_coordinate_y = coordinate_y,
         PC6_coordinate_x = coordinate_x)

nrow(df_activities)
df_activities <- left_join(df_activities, df_PC6_NL_centroids, by='PC6')
nrow(df_activities)

################################################################################
# Select the level of longitude/latitude for the internal activities

print(paste0('[inside activities] unique PC6: ', length(unique(df_activities[df_activities$in_DHZW==1,]$PC6))))

print(paste0('[inside activities] unique PC5: ', length(unique(df_activities[df_activities$in_DHZW==1,]$PC5))))

print(paste0('[outside activities] unique PC4: ', length(unique(df_activities[df_activities$in_DHZW==0,]$PC4))))

print(paste0('PC4 + PC6: ', (length(unique(df_activities[df_activities$in_DHZW==1,]$PC6)) + length(unique(df_activities[df_activities$in_DHZW==0,]$PC4)))))

print(paste0('PC5 + PC6: ', length(unique(df_activities[df_activities$in_DHZW==1,]$PC5)) + length(unique(df_activities[df_activities$in_DHZW==0,]$PC4))))

df_activities$coordinate_y <- NA
df_activities$coordinate_x <- NA

df_activities[df_activities$in_DHZW==0,]$coordinate_y <- df_activities[df_activities$in_DHZW==0,]$PC4_coordinate_y
df_activities[df_activities$in_DHZW==0,]$coordinate_x <- df_activities[df_activities$in_DHZW==0,]$PC4_coordinate_x

df_activities[df_activities$in_DHZW==1,]$coordinate_y <- df_activities[df_activities$in_DHZW==1,]$PC5_coordinate_y
df_activities[df_activities$in_DHZW==1,]$coordinate_x <- df_activities[df_activities$in_DHZW==1,]$PC5_coordinate_x

setwd(this.dir())
setwd('data')
write.csv(df_activities, 'df_activities_locations.csv', row.names = FALSE)

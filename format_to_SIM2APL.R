library(readr)
library(this.path)
library(dplyr)

################################################################################
# Synthetic population

setwd(this.dir())
setwd('../DHZW_synthetic-population/output/synthetic-population-households/4_car_2022-12-26_15-50')
df_synthetic_population <- read.csv('synthetic_population_DHZW_2019.csv')
df_synthetic_population <- df_synthetic_population %>%
  dplyr::rename(pid = agent_ID)

df_synthetic_population$pid <- as.numeric(gsub("[^0-9.-]", "", df_synthetic_population$pid))

################################################################################
# Households
setwd(this.dir())
setwd('../DHZW_locations/data/output')
df_households <- read.csv('df_households_full_info.csv')
df_households$PC4 <-gsub('.{2}$', '', df_households$PC6)

################################################################################
# Activities
setwd(this.dir())
setwd('data')
df_activities <- read.csv('df_activities_locations.csv')
df_activities <- df_activities %>%
  dplyr::rename(pid = agent_ID)
df_activities$pid <- as.numeric(gsub("[^0-9.-]", "", df_activities$pid))

# Shift Sunday at the end of the week
df_activities$day_of_week <- recode(
  df_activities$day_of_week,
  '1' = '7',
  '2' = '1',
  '3' = '2',
  '4' = '3',
  '5' = '4',
  '6' = '5',
  '7' = '6'
)
df_activities$day_of_week <- as.numeric(df_activities$day_of_week)

# Remove all the activities that in a day happens the day after (even better to just delete them when generating the activities...)
df_activities <- df_activities[df_activities$start_time<1400,]

# Calculate time from beginning of the week (required by Sim2APL)
df_activities$start_time_seconds <- (((df_activities$day_of_week-1)*1440) + df_activities$start_time) * 60
df_activities$duration_seconds <- df_activities$duration * 60

# Modify the activity_number from the beginning of the week till the end of it
df_activities <- df_activities %>%
  arrange(pid, start_time_seconds) %>%
  group_by(pid) %>%
  mutate(activity_number = row_number(pid))

# rename column
df_activities <- df_activities %>%
  rename(start_time_within_day = start_time)

df_activities$postcode <- NA
df_activities[df_activities$in_DHZW==1,]$postcode <- as.character(df_activities[df_activities$in_DHZW==1,]$PC5)
df_activities[df_activities$in_DHZW==0,]$postcode <- as.character(df_activities[df_activities$in_DHZW==0,]$PC4)

df_activities <- df_activities %>%
  select(pid, hh_ID, activity_number, activity_type, day_of_week, start_time_seconds, duration_seconds, in_DHZW, postcode, coordinate_y, coordinate_x)

################################################################################
# Sample

df_households_sample <- df_households[sample(nrow(df_households), 100), ]
df_synthetic_population_sample <- df_synthetic_population[df_synthetic_population$hh_ID %in% df_households_sample$hh_ID,]
df_activities_sample <- df_activities[df_activities$pid %in% df_synthetic_population_sample$pid,]

options(scipen=999)

setwd(this.dir())
setwd('output/sample')
write.csv(df_synthetic_population_sample, 'DHZW_synthetic_population_sample.csv', row.names = FALSE, quote=FALSE)
write.csv(df_households_sample, 'DHZW_households_sample.csv', row.names = FALSE, quote=FALSE)
write.csv(df_activities_sample, 'DHZW_activities_locations_sample.csv', row.names = FALSE, quote=FALSE)

table(df_activities_sample$activity_type)

################################################################################
setwd(this.dir())
setwd('output')
write.csv(df_synthetic_population, 'DHZW_synthetic_population.csv', row.names = FALSE, quote=FALSE)
write.csv(df_households, 'DHZW_households.csv', row.names = FALSE, quote=FALSE)
write.csv(df_activities, 'DHZW_activities_locations.csv', row.names = FALSE, quote=FALSE)


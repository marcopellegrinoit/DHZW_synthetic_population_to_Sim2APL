library(dplyr)

extract_trip_frequencies_synthetic_population <- function(df_synth_activities, day, activity_type) {
  df_synth_activities <- df_synth_activities[df_synth_activities$day_of_week==day,]
  
  df_synth_activities <- df_synth_activities %>%
    select(pid, activity_number, PC4, activity_type)
  
  df_synth_trips <- df_synth_activities[order(df_synth_activities$activity_number),]
  df_synth_trips <- df_synth_trips[order(df_synth_trips$pid),]
  
  df_synth_trips <- transform(df_synth_trips, next_PC4 = c(PC4[-1], NA))
  df_synth_trips <- transform(df_synth_trips, next_activity = c(activity_type[-1], NA))
  
  df_synth_trips <- transform(df_synth_trips, nxt_pid = c(as.character(pid[-1]), NA))
  df_synth_trips$next_PC4 <- ifelse(df_synth_trips$nxt_pid == df_synth_trips$pid,
                                    df_synth_trips$next_PC4,
                                    NA)
  df_synth_trips$next_activity <- ifelse(df_synth_trips$nxt_pid == df_synth_trips$pid,
                                         df_synth_trips$next_activity,
                                         NA)
  df_synth_trips <- df_synth_trips[!is.na(df_synth_trips$next_PC4),]
  
  # Select the type of activity
  df_synth_trips <- df_synth_trips[df_synth_trips$next_activity==activity_type,]
  
  ################################################################################
  # proportions in the synthetic activities
  
  df_synth_trips <- df_synth_trips %>%
    select(PC4, next_PC4) %>%
    group_by_all() %>%
    summarise(count = n())
  
  # Proportions per origin PC4
  df_synth_trips$prop <- 0
  for(pc4 in df_synth_trips$PC4) {
    df_synth_trips[df_synth_trips$PC4 == pc4,]$prop <- df_synth_trips[df_synth_trips$PC4 == pc4,]$count/sum(df_synth_trips[df_synth_trips$PC4 == pc4,]$count) * 100
  }
  
  colnames(df_synth_trips) <- c('Departure PC4', 'Arrival PC4', paste0('frequency_', day), paste0('prop_', day))
  
  df_synth_trips$`Departure PC4` <- as.character(df_synth_trips$`Departure PC4`)
  df_synth_trips$`Arrival PC4` <- as.character(df_synth_trips$`Arrival PC4`)
  return(df_synth_trips)
}


extract_trip_frequencies_ODiN <- function(df_ODiN_trips, day, activity_type) {
  df_ODiN_trips <- df_ODiN_trips[df_ODiN_trips$day_of_week==day,]
  
  df_ODiN_trips <- df_ODiN_trips[df_ODiN_trips$disp_activity==activity_type,]
  
  # mark the trips going outside of DHZW
  df_ODiN_trips[!(df_ODiN_trips$disp_arrival_PC4 %in% DHZW_PC4_codes),]$disp_arrival_PC4 <- 'outside_DHZW'
  df_ODiN_trips[!(df_ODiN_trips$disp_start_PC4 %in% DHZW_PC4_codes),]$disp_start_PC4 <- 'outside_DHZW'
  
  df_ODiN_trips <- df_ODiN_trips %>%
    select(disp_start_PC4, disp_arrival_PC4)
  
  # COunt frequencies
  df_ODiN_trips <- df_ODiN_trips %>%
    group_by_all() %>%
    summarise(count = n())
  
  # Proportions per origin PC4
  df_ODiN_trips$prop <- 0
  for(pc4 in df_ODiN_trips$disp_start_PC4) {
    df_ODiN_trips[df_ODiN_trips$disp_start_PC4 == pc4,]$prop <- df_ODiN_trips[df_ODiN_trips$disp_start_PC4 == pc4,]$count/sum(df_ODiN_trips[df_ODiN_trips$disp_start_PC4 == pc4,]$count) * 100
  }
  
  colnames(df_ODiN_trips) <- c('Departure PC4', 'Arrival PC4', paste0('frequency_', day), paste0('prop_', day))
  
  df_ODiN_trips$`Departure PC4` <- as.character(df_ODiN_trips$`Departure PC4`)
  df_ODiN_trips$`Arrival PC4` <- as.character(df_ODiN_trips$`Arrival PC4`)
  
  return(df_ODiN_trips)
}
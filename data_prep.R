library(tidyverse)
library(here)
library(stringr)
library(doParallel)
library(parallel)
library(sf)

setup_cl = function(seed = as.numeric(round(Sys.time()))) {
  require(parallel)
  if (exists("cl")) {
    print("Stopping existing cluster")
    result = tryCatch({
      parallel::stopCluster(cl)
    }, warning = function(w) {
      print(w)
    }, error = function(e) {
      print(e)
    })
  }
  result = tryCatch({
    file.remove(here("out.txt"))
  }, warning = function(w) {
    print(w)
  }, error = function(e) {
    print(e)
  })
  assign("cl", parallel::makeCluster(parallel::detectCores() - 1, outfile = "out.txt"), envir = globalenv())
  RNGkind("L'Ecuyer-CMRG")
  print(paste("Using", as.numeric(seed), "as parallel RNG seed"))
  clusterSetRNGStream(cl, seed)
}

stop_cl = function() {
  parallel::stopCluster(cl)
  rm(cl)
}

setup_cl(60615)
registerDoParallel(cl)

years = 2014:2018
chi_crime_data = read_csv(here("Data", "Crimes_2001_on_4-26-19.csv")) %>% filter(Year %in% years)

index_range = 1:length(chi_crime_data$ID)

#chi_crime_data = chi_crime_data[index_range,]

start_time = proc.time()
process_line_wrapper = function(i, max_len) {
  require(tidyverse)
  
  process_date_line = function(date_line) {
    date_line = stringr::str_split(date_line, " ")[[1]]
    
    time_to_decimal = function(time, evening) {
      convert_hour = function(hour) {
        if (hour == 12) {
          return(0)      
        }
        return(hour)
      }
      time = as.numeric(stringr::str_split(time, ":")[[1]])
      if (evening) {
        if (length(time) == 2) {
          return(convert_hour(time[1]) + 12 + time[2] / 60)
        }
        if(length(time) == 3) {
          return(convert_hour(time[1]) + 12 + time[2] / 60 + time[3] / 3600)
        }  
      } else {
        if (length(time) == 2) {
          return(convert_hour(time[1]) + time[2] / 60)
        }
        if(length(time) == 3) {
          return(convert_hour(time[1]) + time[2] / 60 + time[3] / 3600)
        }  
        
      }
      
      return(NA)                              
    }
    
    get_tod = function(num_time){
      if(num_time < 6) {
        return("Night")
      }
      if(num_time < 12) {
        return("Morning")
      }
      if(num_time < 18) {
        return("Afternoon")
      }
      return("Evening")
    }
    
    temp_date = as.Date(date_line[1], "%m/%d/%Y")
    temp_time = time_to_decimal(date_line[2], stringr::str_to_lower(date_line[3]) == "pm")
    temp_tod = get_tod(temp_time)
    return(tibble::tibble(Date = temp_date, 
                          Time = temp_time, 
                          Day = weekdays(temp_date), 
                          Month = months(temp_date), 
                          TimeOfDay = temp_tod, 
                          Night = (temp_tod == "Evening" | temp_tod == "Night") ))
  }
  
  line_tb = process_date_line(.GlobalEnv$chi_crime_data$Date[i])[1,]
  #time_date_tb[i, ] = line_tb
  return(line_tb)
}

clusterExport(cl=cl, varlist=c("chi_crime_data"))
dt_tb = parSapply(cl, index_range, process_line_wrapper, length(index_range)) %>% as.matrix(test, ncol = 6) %>% t() %>% as_tibble()
dt_tb$Date = as.Date(unlist(dt_tb$Date), "1970-01-01")
dt_tb$Time = as.numeric(unlist(dt_tb$Time))
dt_tb$Day = unlist(dt_tb$Day) %>% factor(levels = c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))
dt_tb$Month = unlist(dt_tb$Month) %>% factor(levels = c("January", "February", "March", "April", "May",
                                                        "June", "July", "August", "September", "October", "November", "December"))
dt_tb$TimeOfDay = unlist(dt_tb$TimeOfDay) %>% factor(levels = c("Morning", "Afternoon", "Evening", "Night"))
dt_tb$Night = unlist(dt_tb$Night)

chi_crime_data_final = chi_crime_data[1:2] %>% bind_cols(dt_tb) %>% bind_cols(chi_crime_data[4:length(chi_crime_data)])
chi_crime_data_final = chi_crime_data_final[1:13] %>% bind_cols(tibble(`Violent Crime` = chi_crime_data_final$`Primary Type` %in% c('ARSON', 'ASSAULT', 'BATTERY', 'BURGLARY', 'CONCEALED CARRY LICENSE VIOLATION', 'CRIM SEXUAL ASSAULT', 'CRIMINAL DAMAGE', 'HOMICIDE', 'HUMAN TRAFFICKING', 'KIDNAPPING', 'OFFENSE INVOLVING CHILDREN', 'ROBBERY', 'THEFT', 'WEAPONS VIOLATION'), `In Vehicle` = chi_crime_data_final$`Location Description` %in% c('VEHICLE - OTHER RIDE SHARE SERVICE (E.G., UBER, LYFT)', 'VEHICLE NON-COMMERCIAL', 'CTA TRAIN', 'TAXICAB', 'VEHICLE - DELIVERY TRUCK', 'OTHER COMMERCIAL TRANSPORTATION', 'CTA BUS', 'AIRCRAFT', 'AUTO', 'TRUCK', 'VEHICLE-COMMERCIAL', 'BOAT/WATERCRAFT', 'VEHICLE-COMMERCIAL - ENTERTAINMENT/PARTY BUS', 'VEHICLE-COMMERCIAL - TROLLEY BUS', 'AIRPORT TRANSPORTATION SYSTEM (ATS)', 'AIRPORT/AIRCRAFT', 'VEHICLE - OTHER RIDE SERVICE', 'CTA \"L\" TRAIN', 'DELIVERY TRUCK'), `In Building` = chi_crime_data_final$`Location Description` %in% c('APARTMENT', 'MOVIE HOUSE/THEATER', 'RESIDENCE', 'AIRPORT BUILDING NON-TERMINAL - NON-SECURE AREA', 'HOTEL/MOTEL', 'RESIDENCE-GARAGE', 'SMALL RETAIL STORE', 'DEPARTMENT STORE', 'CTA STATION', 'CHURCH/SYNAGOGUE/PLACE OF WORSHIP', 'BANK', 'CHA APARTMENT', 'ATM (AUTOMATIC TELLER MACHINE)', 'HOSPITAL BUILDING/GROUNDS', 'AUTO / BOAT / RV DEALERSHIP', 'BARBERSHOP', 'ATHLETIC CLUB', 'ABANDONED BUILDING', 'AIRPORT TERMINAL UPPER LEVEL - NON-SECURE AREA', 'SPORTS ARENA/STADIUM', 'OTHER RAILROAD PROP / TRAIN DEPOT', 'GOVERNMENT BUILDING/PROPERTY', 'CLEANING STORE', 'POOL ROOM', 'FACTORY/MANUFACTURING BUILDING', 'HOUSE', 'AIRPORT BUILDING NON-TERMINAL - SECURE AREA', 'COLLEGE/UNIVERSITY RESIDENCE HALL', 'CREDIT UNION', 'LIBRARY', 'AIRPORT TERMINAL MEZZANINE - NON-SECURE AREA', 'AIRPORT TERMINAL LOWER LEVEL - SECURE AREA', 'STAIRWELL', 'FEDERAL BUILDING', 'SAVINGS AND LOAN', 'HOSPITAL', 'BARBER SHOP/BEAUTY SALON', 'OFFICE', 'HORSE STABLE', 'GAS STATION DRIVE/PROP.', 'KENNEL', 'LIQUOR STORE', 'RETAIL STORE', 'YMCA', 'ROOMING HOUSE', 'TAVERN', 'CHURCH', 'VESTIBULE', 'NURSING HOME', 'CLEANERS/LAUNDROMAT', 'POOLROOM', 'BAR OR TAVERN', 'GAS STATION', 'RESTAURANT', 'NURSING HOME/RETIREMENT HOME', 'RESIDENCE PORCH/HALLWAY', 'COMMERCIAL / BUSINESS OFFICE', 'CONVENIENCE STORE', 'DRUG STORE', 'GROCERY FOOD STORE', 'APPLIANCE STORE', 'CURRENCY EXCHANGE', 'AIRPORT TERMINAL UPPER LEVEL - SECURE AREA', 'SCHOOL, PRIVATE, BUILDING', 'WAREHOUSE', 'TAVERN/LIQUOR STORE', 'PAWN SHOP', 'MEDICAL/DENTAL OFFICE', 'BOWLING ALLEY', 'AIRPORT TERMINAL LOWER LEVEL - NON-SECURE AREA', 'CHA HALLWAY/STAIRWELL/ELEVATOR', 'JAIL / LOCK-UP FACILITY', 'SCHOOL, PUBLIC, BUILDING', 'DAY CARE CENTER', 'GANGWAY', 'ANIMAL HOSPITAL', 'NEWSSTAND', 'FIRE STATION', 'GARAGE', 'HOTEL', 'HALLWAY', 'GARAGE/AUTO REPAIR', 'GOVERNMENT BUILDING', 'BASEMENT', 'CHA HALLWAY', 'CLUB', 'LAUNDRY ROOM', 'ELEVATOR'))) %>% bind_cols(chi_crime_data_final[14:length(chi_crime_data)])
chi_crime_data_final = chi_crime_data_final %>% filter(!is.na(chi_crime_data_final$Location)) %>% st_as_sf(coords = c("Latitude", "Longitude"))
saveRDS(chi_crime_data_final, file = here("chi_crime_data_cleaned"))
proc.time() - start_time




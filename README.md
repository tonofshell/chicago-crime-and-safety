Chicago Crime and Safety
================

## Background

## About the Data

``` r
chi_crime_data = readRDS(here("Data", "chi_crime_data_cleaned.rds"))

data_sample = chi_crime_data %>% head(5) 
data_sample$Date = as.character(data_sample$Date)
data_sample%>% kable(format = "markdown")
```

|       ID | Case Number | Date       |     Time | Day    | Month    | TimeOfDay | Night | Block                  | IUCR | Primary Type       | Description                          | Location Description | Violent Crime | In Vehicle | In Building | Arrest | Domestic | Beat | District | Ward | Community Area | FBI Code | X Coordinate | Y Coordinate | Year | Updated On             | Location                      | Historical Wards 2003-2015 | Zip Codes | Community Areas | geometry                       |
| -------: | :---------- | :--------- | -------: | :----- | :------- | :-------- | :---- | :--------------------- | :--- | :----------------- | :----------------------------------- | :------------------- | :------------ | :--------- | :---------- | :----- | :------- | :--- | :------- | ---: | -------------: | :------- | -----------: | -----------: | ---: | :--------------------- | :---------------------------- | -------------------------: | --------: | --------------: | :----------------------------- |
| 11561837 | JC110056    | 2018-12-31 | 23.98333 | Monday | December | Evening   | TRUE  | 013XX W 72ND ST        | 1153 | DECEPTIVE PRACTICE | FINANCIAL IDENTITY THEFT OVER $ 300  | NA                   | FALSE         | FALSE      | FALSE       | FALSE  | FALSE    | 0734 | 007      |    6 |             67 | 11       |      1168573 |      1857018 | 2018 | 01/17/2019 02:26:36 PM | (41.763181359, -87.657709477) |                         17 |     22257 |              65 | c(41.763181359, -87.657709477) |
| 11556487 | JC104662    | 2018-12-31 | 23.98333 | Monday | December | Evening   | TRUE  | 112XX S SACRAMENTO AVE | 1320 | CRIMINAL DAMAGE    | TO VEHICLE                           | STREET               | TRUE          | FALSE      | FALSE       | FALSE  | FALSE    | 2211 | 022      |   19 |             74 | 14       |      1158309 |      1829936 | 2018 | 01/10/2019 03:16:50 PM | (41.689078832, -87.696064026) |                         33 |      4447 |              73 | c(41.689078832, -87.696064026) |
| 11552699 | JC100043    | 2018-12-31 | 23.95000 | Monday | December | Evening   | TRUE  | 084XX S SANGAMON ST    | 1310 | CRIMINAL DAMAGE    | TO PROPERTY                          | APARTMENT            | TRUE          | FALSE      | TRUE        | FALSE  | FALSE    | 0613 | 006      |   21 |             71 | 14       |      1171454 |      1848783 | 2018 | 01/10/2019 03:16:50 PM | (41.740520866, -87.647390719) |                         18 |     21554 |              70 | c(41.740520866, -87.647390719) |
| 11552724 | JC100006    | 2018-12-31 | 23.93333 | Monday | December | Evening   | TRUE  | 018XX S ALLPORT ST     | 0440 | BATTERY            | AGG: HANDS/FIST/FEET NO/MINOR INJURY | OTHER                | TRUE          | FALSE      | FALSE       | TRUE   | FALSE    | 1233 | 012      |   25 |             31 | 08B      |      1168327 |      1891230 | 2018 | 01/10/2019 03:16:50 PM | (41.857068095, -87.657625201) |                          8 |     14920 |              33 | c(41.857068095, -87.657625201) |
| 11552731 | JC100031    | 2018-12-31 | 23.91667 | Monday | December | Evening   | TRUE  | 078XX S SANGAMON ST    | 0486 | BATTERY            | DOMESTIC BATTERY SIMPLE              | APARTMENT            | TRUE          | FALSE      | TRUE        | FALSE  | FALSE    | 0621 | 006      |   17 |             71 | 08B      |      1171332 |      1852934 | 2018 | 01/10/2019 03:16:50 PM | (41.75191443, -87.647716532)  |                         17 |     21554 |              70 | c(41.75191443, -87.647716532)  |

``` r
num_obs= chi_crime_data$ID %>% length()
num_vars = chi_crime_data[1,] %>% unlist() %>% length()
```

The data set has 1327334 observations and 33 variables.

## Cleaning the Data

## Initial Analysis

## Prediciton

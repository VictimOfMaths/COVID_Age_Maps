rm(list=ls())

library(tidyverse)
library(curl)
library(sf)

#Read in case data from dashboard
source <- "https://api.coronavirus.data.gov.uk/v2/data?areaType=ltla&metric=newCasesBySpecimenDateAgeDemographics&format=csv"

temp <- tempfile()
temp <- curl_download(url=source, destfile=temp, quiet=FALSE, mode="wb")

data <- read.csv(temp) %>% 
  select(date, areaCode, age, rollingRate) %>% 
  mutate(date=as.Date(date),
         age=gsub("_", "-", age)) 

maxdate=max(data$date)

data <- data %>%   
  group_by(areaCode, age) %>% 
  arrange(date) %>% 
  slice_tail(n=8) %>% 
  ungroup() %>% 
  spread(date, rollingRate) %>% 
  select(c(1,2,3,10)) %>% 
  set_names("Lacode", "age", "prev", "latest") %>% 
  mutate(abschange=latest-prev, relchange=abschange/prev)

#Download Carl Baker's lovely map
ltla <- tempfile()
source <- ("https://github.com/houseofcommonslibrary/uk-hex-cartograms-noncontiguous/raw/main/geopackages/LocalAuthorities-lowertier.gpkg")
ltla <- curl_download(url=source, destfile=ltla, quiet=FALSE, mode="wb")

Background <- st_read(ltla, layer="7 Background") %>% 
  filter(Name=="England & Wales")

ltlacases <- st_read(ltla, layer="4 LTLA-2019") %>% 
  left_join(data, by="Lacode")

Groups <- st_read(ltla, layer="2 Groups") %>% 
  filter(!RegionNation %in% c("Wales", "Scotland", "Northern Ireland"))

Group_labels <- st_read(ltla, layer="1 Group labels") %>% 
  filter(!RegionNation %in% c("Wales", "Scotland", "Northern Ireland"))%>% 
  mutate(just=if_else(LabelPosit=="Left", 0, 1))

save(Background, ltlacases, Groups, Group_labels, file="COVID_Age_Maps/Mapdata.RData")
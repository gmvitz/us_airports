library(ggplot2)
library(stringr)
library(dplyr)
library(here)
library(rio)

air <- import(here("data", "us_airports.csv"), setclass = "tbl_df") %>% 
  select(everything(), -V1)
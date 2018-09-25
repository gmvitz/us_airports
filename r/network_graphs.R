library(ggplot2)
library(stringr)
library(dplyr)
library(here)
library(rio)

air <- import(here("data", "us_airports.csv"), setclass = "tbl_df") %>% 
    select(everything(), -V1)

ports <- import(here("data", "airports.csv"), setclass = "tbl_df")

us <- map_data(map = "state") 

airports <- left_join(air, ports, by = c("loc_id" = "V5")) %>% 
    select(
        yearly_rank:passengers,
        lat = V7,
        long = V8,
        alt = V9) %>% 
    mutate(state = state.name[match(state, state.abb)]) %>% 
    mutate_if(
        is.character, str_to_lower) %>% 
    filter(state %in% str_to_lower(state.name),
           state != "alaska",
           state != "hawaii",
           passengers != 0,
           between(lat, min(us$lat), max(us$lat)),
           between(long, min(us$long), max(us$long)),
           year == 2016)


# Begin creating the map

mapplot <- ggplot() +
    geom_map(data = airports, map = us,
             aes(map_id = state),
             color = "white") +
    geom_point(data = airports, 
               aes(x = long, y = lat, color = region, 
                   size = passengers)) +
    expand_limits(x=us$long, y=us$lat) +
    coord_map("albers", lat0 = 39, lat1 = 45) +
    scale_size_continuous(labels = scales::comma) +
    theme(
          panel.grid = element_blank(),
          panel.grid.minor = element_blank()
          )

ggsave("state_map.png", plot = mapplot, path = "plots/")

library(targets)
library(tarchetypes)
library(tibble)
options(clustermq.scheduler = "multiprocess")
library(clustermq)

options(tidyverse.quiet = TRUE)
tar_option_set(packages = c("tidyverse", "dataRetrieval"), error = 'abridge')


# Load functions needed by targets below
source("1_fetch/src/find_oldest_sites.R")
source("1_fetch/src/get_site_data.R")

# Configuration
states <- c('WI','MN','MI', 'IL', 'IN', 'IA')
parameter <- c('00060')

# Targets
list(
  # Identify oldest sites
  tar_target(oldest_active_sites, find_oldest_sites(states, parameter)),

  # PULL SITE DATA
  tar_map(
    values = tibble(state_abb = states),
    tar_target(nwis_inventory, get_state_inventory(sites_info = oldest_active_sites, state_abb)),
    tar_target(nwis_data, get_site_data(nwis_inventory, state_abb, parameter))
    # Insert step for tallying data here
    # Insert step for plotting data here
  )
)

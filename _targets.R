library(dplyr)
library(palmerpenguins)
library(tarchetypes)
library(targets)
tar_option_set(packages = c("palmerpenguins"))
#options(clustermq.scheduler = "multiprocess")
spp = as.character(unique(penguins$species))
list(
  tar_target(penguins_cleaned,
             filter(penguins,
                    ! is.na(body_mass_g),
                    ! is.na(sex))),
  tar_map(
    values = tibble(spp = spp),
    names = spp,
    tar_target(sp, filter(penguins_cleaned, species == spp)),
    tar_target(mean_body_mass, mean(sp$body_mass_g / 1000)),
    tar_target(male_female_ratio, sum(sp$sex == "male") / sum(sp$sex == "female"))
    )
)

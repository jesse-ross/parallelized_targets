# Load the packages
lapply(X = c("targets", "future", "future.batchtools",
             "tidyverse", "data.table", "foreign", "stringr",
             "tarchetypes"),
       FUN = require, character.only = TRUE)

source("R/functions.R")

tar_option_set(packages = c("tidyverse", "data.table"),
               resources = 
                       tar_resources(
                               
                               future = tar_resources_future(
                                       list(
                                               partition = 'cahnrs',
                                               walltime = 604800,
                                               ncpus = 1,
                                               #measure.memory = TRUE,
                                               #user_email = 'matthew.brousil@wsu.edu',
                                               memory = 256000
                                       ))
                       )
               
               
               
               
)

plan(strategy = batchtools_slurm(),
     template = "batchtools.slurm.tmpl")


# The eponymous targets:
list(
        
        # # Paths for targets to track as external input files ----------------------
        # # https://books.ropensci.org/targets/files.html#external-input-files
        # # https://docs.ropensci.org/tarchetypes/reference/tar_files_input.html?q=tar%20_%20files%20input
        # tar_file(name = snow_na_path,
        #          command = "../data/inputs/snow/na_pivot.csv"),
        # 
        # tar_file(name = snow_path,
        #          command = "../data/inputs/snow/"),  
        # 
        # tar_file(name = ice_path,
        #          command = "../data/inputs/monthly_lake_ice/"),
        # 
        tar_file(name = hydrolakes_path,
                 command = "/data/katz/projects/GLCP_analysis_mfm/data/inputs/hydrolakes.csv"),
        
        tar_file(name = hydrobasins_path,
                 command = "/data/katz/projects/GLCP_analysis_mfm/data/inputs/all_valid_basins.csv"),
        
        tar_file(name = glcp_path,
                 command = "/data/katz/projects/GLCP_analysis_mfm/data/inputs/glcp.csv"),
        
        tar_file(name = glup_path,
                 command = "../data/inputs/glup_pop/GLUP95G/"),
        
        tar_file(name = humidity_path,
                 command = "../data/inputs/humidity_average"),
        
        tar_file(name = temperature_path,
                 command = "../data/inputs/temperature_average"),
        
        tar_file(name = clouds_path,
                 command = "../data/inputs/totcloud_average"),
        
        tar_file(name = precipitation_path,
                 command = "../data/inputs/precipitation_average"),
        
        tar_file(name = shortwave_path,
                 command = "../data/inputs/sw_average"),
        
        tar_file(name = longwave_path,
                 command = "../data/inputs/lw_average"),
        
        
        # # Read and process data ---------------------------------------------------
        # 
        # tar_target(
        #         name = ice_data,
        #         command = preprocess_ice(ice_path = ice_path)),
        # 
        # tar_target(
        #         snow_data,
        #         preprocess_snow(snow_path = snow_path,
        #                         snow_na_path = snow_na_path)),
        # 
        tar_target(
                humidity_data,
                process_gee_humidity(humidity_path = humidity_path)),
        
        tar_target(
                temp_data,
                process_gee_temperature(temperature_path = temperature_path)),
        
        tar_target(
                cloud_data,
                process_gee_clouds(clouds_path = clouds_path)),
        
        tar_target(
                precip_data,
                process_gee_precip(precipitation_path = precipitation_path)),
        
        tar_target(
                swave_data,
                process_gee_shortwave(shortwave_path = shortwave_path)),
        
        tar_target(
                lwave_data,
                process_gee_longwave(longwave_path = longwave_path)),
        
        # https://github.com/ropensci/tarchetypes - Is there something here better
        # for reading in files?
        tar_target(
                h_lakes,
                fread(file = hydrolakes_path, integer64 = "character") %>%
                        select(-FID),
                resources = 
                        tar_resources(
                                
                                future = tar_resources_future(
                                        list(partition = 'katz',
                                             ncpus = 1,
                                             memory = 240000,
                                             walltime = 604800))
                        ))
        
        ,
        
        tar_target(
                h_basins,
                fread(file = hydrobasins_path, integer64 = "character"),
                resources = 
                        tar_resources(
                                
                                future = tar_resources_future(
                                        
                                        list(partition = 'katz',
                                             ncpus = 1,
                                             memory = 240000,
                                             walltime = 604800))
                        )),
        tar_target(
                glcp_data,
                fread(file = glcp_path, integer64 = "character") %>%
                        # Sample a subset of the hylak_ids to test the workflow
                        filter(Hylak_id %in% sample(x = unique(Hylak_id),
                                                    size = 10000)),
                resources = 
                        
                        tar_resources(
                                
                                future = tar_resources_future(
                                        list(partition = 'katz',
                                             ncpus = 1,
                                             memory = 240000,
                                             walltime = 604800))
                        )),
        
        
        # Join constituent datasets -----------------------------------------------
        
        tar_target(
                glcp_l,
                left_join(x = glcp_data, y = h_lakes,
                          by = c("Hylak_id")),
                resources = 
                        tar_resources(
                                
                                future = tar_resources_future(
                                        list(partition = 'katz',
                                             ncpus = 1,
                                             memory = 240000,
                                             walltime = 604800))
                        ))
        ,
        
        tar_target(
                glcp_lb,
                left_join(x = glcp_l, y = h_basins,
                          by = c("HYBAS_ID", "bsn_lvl")),
                resources = tar_resources(
                        
                        future = tar_resources_future(
                                list(partition = 'katz',
                                     ncpus = 1,
                                     memory = 240000,
                                     walltime = 604800))
                )),
        
        
        # Create GLUP product
        tar_target(
                glup,
                create_1995_pop_counts(glup_path = glup_path)),
        
        # Track the new GLUP product file
        tar_file(name = glup_out_path,
                 command = glup$glup_out_path),
        
        
        # Lake-basin ratios
        tar_target(
                lb_ratios,
                calculate_lb_ratios(h_lakes = h_lakes,
                                    h_basins = h_basins,
                                    glcp_data = glcp_data)),
        
        # Track output file
        tar_file(name = lb_ratio_path,
                 command = lb_ratios$ratio_list_path),
        
        # Isolate unique HYBAS_IDs from GLCP for downstream use
        tar_target(
                unique_hybas,
                unique(select(glcp_lb, HYBAS_ID))),
        
        # Join humidity
        tar_target(
                glcp_humidity,
                merge_glcp_humidity(unique_hybas = unique_hybas,
                                    current_glcp_merge = glcp_lb,
                                    humidity_average = humidity_data$climate_data)),
        
        # Join precip
        tar_target(
                glcp_precip,
                merge_glcp_precip(unique_hybas = unique_hybas,
                                  current_glcp_merge = glcp_humidity,
                                  precip_average = precip_data$climate_data)),
        
        
        # Join temp
        tar_target(
                glcp_temp,
                merge_glcp_temp(unique_hybas = unique_hybas,
                                current_glcp_merge = glcp_humidity,
                                temp_average = temp_data$climate_data)),
        
        # Join cloud
        tar_target(
                glcp_cloud,
                merge_glcp_cloud(unique_hybas = unique_hybas,
                                 current_glcp_merge = glcp_temp,
                                 cloud_average = cloud_data$climate_data)),
        
        # Join swave
        tar_target(
                glcp_swave,
                merge_glcp_swave(unique_hybas = unique_hybas,
                                 current_glcp_merge = glcp_cloud,
                                 swave_average = swave_data$climate_data)),
        
        # Join lwave
        tar_target(
                glcp_lwave,
                merge_glcp_lwave(unique_hybas = unique_hybas,
                                 current_glcp_merge = glcp_swave,
                                 lwave_average = lwave_data$climate_data)),
        
        # Join GLUP
        tar_target(
                glcp_pop,
                merge_glcp_glup(unique_hybas = unique_hybas,
                                current_glcp_merge = glcp_lwave,
                                glup_1995 = glup$glup)),
        
        # Join lake-basin ratios
        tar_target(
                glcp_ratio,
                merge_glcp_ratio(lb_ratio = lb_ratios$ratio_list,
                                 current_glcp_merge = glcp_pop)),
        
        # Track output file
        tar_file(name = glcp_ratio_path,
                 command = glcp_ratio$glcp_ratio_path)
        
        # # Join ice
        # tar_target(
        #         glcp_ice,
        #         merge_glcp_ice(current_glcp_merge = glcp_ratio$glcp_ratio,
        #                        ice_data = ice_data)),
        # 
        # # Join snow for the final extended GLCP product
        # tar_target(
        #         glcp_final,
        #         merge_glcp_snow(current_glcp_merge = glcp_ice,
        #                         snow_data = snow_data)),
        # 
        # # Track output file
        # tar_file(name = glcp_final_path,
        #          command = glcp_final$glcp_final_path)
        
        
        # Quality control ---------------------------------------------------------
        
        
)


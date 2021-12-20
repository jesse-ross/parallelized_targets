library(targets)                                                                                                        tar_option_set(packages = c("palmerpenguins"))
options(clustermq.scheduler = "multiprocess")
list(
  tar_target(data, get_data()),
  tar_target(fast_fit, fit_small_model(data)),
  tar_target(slow_fit, fit_slow_model(data)),
  tar_target(plot_1, make_plot(fast_fit)),
  tar_target(plot_2, make_plot(slow_fit))
)

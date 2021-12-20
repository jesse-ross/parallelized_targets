library(foreach)
clustermq::register_dopar_cmq(n_jobs=2, memory=1024) # this accepts same arguments as `Q`
x = foreach(i=1:3) %do% sqrt(i)

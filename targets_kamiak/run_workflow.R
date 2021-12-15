library(targets)

# tar_destroy()

tar_make_future(
  workers = 3)

visNetwork::visSave(tar_visnetwork(), file = "test.html")

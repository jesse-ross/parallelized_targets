FROM rocker/tidyverse:latest

# Disable the annoying bell on WSL2
RUN sed -i 's/^# set bell-style none$/set bell-style none/' /etc/inputrc

# Add DOI CA to local CAs so that SSL can work over VPN
COPY DOIRootCA2.crt /usr/local/share/ca-certificates
RUN update-ca-certificates

# Dependencies: ZeroMQ library for clustermq and libglpk40 for igraph/targets
RUN apt-get update && apt-get install -y \
  libglpk40 \
  libzmq3-dev \
  vim-tiny \
  && rm -rf /var/lib/apt/lists/*

# Set a default scheduler for clustermq
COPY .Rprofile /root/.Rprofile

# Install the clustermq and targets R packages
RUN install2.r --error \
  clustermq \
  dataRetrieval \
  tarchetypes \
  targets \
  && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

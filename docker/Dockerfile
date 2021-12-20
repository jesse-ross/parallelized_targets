FROM rocker/tidyverse:latest

# Disable the annoying bell on WSL2
RUN sed -i 's/^# set bell-style none$/set bell-style none/' /etc/inputrc

# Add DOI CA to local CAs so that SSL can work over VPN
COPY DOIRootCA2.crt /usr/local/share/ca-certificates
RUN update-ca-certificates

# Install ZeroMQ libraries
RUN apt-get update && apt-get install -y \
  libzmq3-dev \
  && rm -rf /var/lib/apt/lists/*


RUN Rscript -e 'install.packages("clustermq")'

COPY .Rprofile /root/.Rprofile

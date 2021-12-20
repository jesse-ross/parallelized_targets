FROM rocker/tidyverse:latest

# Add DOI CA to local CAs so that SSL can work over VPN
COPY DOIRootCA2.crt /usr/local/share/ca-certificates
RUN update-ca-certificates

ARG ALLOY_VERSION=v1.20.1
FROM grafana/alloy:${ALLOY_VERSION}
# Loaded as one config from the directory: the package's config.alloy
# (vendored, see PACKAGE_VERSION) plus the OpenLMIS additions.
COPY config.alloy openlmis.alloy /etc/alloy/

FROM alpine:3.21

WORKDIR /stage

COPY log/ ./log/
COPY scalyr/ ./scalyr/

RUN find ./log ./scalyr -type d -exec chmod 755 {} + && \
    find ./log ./scalyr -type f -exec chmod 644 {} +

CMD ["sh", "-c", "cp -a /stage/. /config/"]

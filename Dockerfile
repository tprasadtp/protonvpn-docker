FROM alpine:3.13.0

COPY root/ /

ENTRYPOINT ["healthcheck"]

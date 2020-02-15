ARG TAG=latest
FROM alpine:${TAG}

ARG TAG
ENV BASE_IMAGE=alpine:${TAG}
RUN apk update && \
    apk --no-cache add cifs-utils rsync tzdata && \
    # ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    date +"%Z %z"

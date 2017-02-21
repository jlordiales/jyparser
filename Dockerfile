FROM alpine:3.3

RUN apk add --update jq \
                     python \
                     python-dev \
                     py-pip \
                     bash \
    && rm -rf /var/cache/apk/* \
    && pip install pyyaml

COPY ./start /bin/start

WORKDIR /jyparser
ENTRYPOINT ["/bin/start"]

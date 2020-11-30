FROM quay.io/ibmz/docker:18.06.3-ce AS docker-cli

FROM quay.io/ibmz/golang:1.14

COPY --from=docker-cli /usr/local/bin/docker /usr/local/bin/docker

RUN apk add --no-cache --virtual .build-deps make; \
    apk add --no-cache dumb-init; \
    git clone https://github.com/lcarcaramo/clair-scanner.git; \
    cd clair-scanner; \
    make installLocal; \
    apk del .build-deps
    
ENTRYPOINT [ "/usr/bin/dumb-init", "--", "/go/bin/clair-scanner" ]

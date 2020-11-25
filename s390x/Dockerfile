FROM quay.io/ibmz/docker:18.06.3-ce AS docker-cli

FROM quay.io/ibmz/golang:1.14

COPY --from=docker-cli /usr/local/bin/docker /usr/local/bin/docker

RUN apk add --no-cache --virtual .build-deps \
                                  make \
                                  dumb-init; \
    git clone https://github.com/arminc/clair-scanner.git; \
    cd clair-scanner; \
    make installLocal; \
    apk del .build-deps
    
ENTRYPOINT [ "/usr/bin/dumb-init", "--", "/go/bin/clair-scanner" ]

FROM alpine:3.10 as build
MAINTAINER "Vitali Khlebko vitali.khlebko@vetal.ca"

ARG POSTGRES_TAG=REL_12_0

RUN apk update && apk add git g++ make readline-dev zlib-dev perl bison flex linux-headers

RUN cd /tmp &&\
    git clone https://github.com/postgres/postgres.git postgres &&\
    cd postgres &&\
    git checkout ${POSTGRES_TAG} &&\
    git config pull.rebase true &&\
    ./configure &&\
    make &&\
    make install

FROM alpine:3.10

COPY --from=build /usr/local/pgsql /usr/local/pgsql

ENV LANG en_US.utf8
ENV PGDATA /var/lib/postgresql/data
ENV PATH="/usr/local/pgsql/bin:${PATH}"

COPY docker-entrypoint.sh /scripts/docker-entrypoint.sh
#    addgroup -g 70 postgres &&\
#    adduser -H -D -u 70 -s /bin/sh -h :/var/lib/postgresql -g "" postgres &&\

RUN apk update && apk add su-exec bash &&\
    mkdir -p $PGDATA &&\
    mkdir -p /var/run/postgresql &&\
    mkdir /docker-entrypoint-initdb.d &&\
    chown -R postgres:postgres /var/run/postgresql

ENTRYPOINT ["/scripts/docker-entrypoint.sh"]
CMD ["postgres"]
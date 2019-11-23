FROM alpine:3.10 as build
MAINTAINER "Vitali Khlebko vitali.khlebko@vetal.ca"

ARG QUAGGA_TAG=quagga-1.2.4

RUN apk update && apk add git automake libtool texinfo gawk g++ autoconf pkgconfig readline-dev \
	make linux-headers

RUN cd /tmp &&\
	git clone https://github.com/c-ares/c-ares.git &&\
	cd c-ares &&\
	./buildconf && ./configure && make && make install

RUN cd /tmp &&\
    git clone https://github.com/Quagga/quagga.git &&\
    cd quagga &&\
    git checkout ${QUAGGA_TAG} &&\
    git config pull.rebase true &&\
	 ./bootstrap.sh &&\
	 ./configure --disable-doc --enable-user=root --enable-group=root --with-cflags=-ggdb --sysconfdir=/etc/quagga --enable-vtysh   --localstatedir=/var/run/quagga &&\
	 make && make install

FROM alpine:3.10

RUN mkdir -p /etc/quagga/

COPY --from=build /usr/local/bin/bgp_btoa /usr/local/bin/bgp_btoa
COPY --from=build /usr/local/bin/test_igmpv3_join /usr/local/bin/test_igmpv3_join
COPY --from=build /usr/local/bin/vtysh /usr/local/bin/vtysh
COPY --from=build /usr/local/lib/libfpm_pb.* /usr/local/lib/
COPY --from=build /usr/local/lib/libospf* /usr/local/lib/
COPY --from=build /usr/local/lib/libquagga* /usr/local/lib/
COPY --from=build /usr/local/lib/libzebra.* /usr/local/lib/
COPY --from=build /usr/local/sbin/bgpd /usr/local/sbin/bgpd
COPY --from=build /usr/local/sbin/isisd /usr/local/sbin/isisd
COPY --from=build /usr/local/sbin/nhrpd /usr/local/sbin/nhrpd
COPY --from=build /usr/local/sbin/ospf6d /usr/local/sbin/ospf6d
COPY --from=build /usr/local/sbin/ospfclient /usr/local/sbin/ospfclient
COPY --from=build /usr/local/sbin/ospfd /usr/local/sbin/ospfd
COPY --from=build /usr/local/sbin/pimd /usr/local/sbin/pimd
COPY --from=build /usr/local/sbin/ripd /usr/local/sbin/ripd
COPY --from=build /usr/local/sbin/ripngd /usr/local/sbin/ripngd
COPY --from=build /usr/local/sbin/watchquagga /usr/local/sbin/watchquagga
COPY --from=build /usr/local/sbin/zebra /usr/local/sbin/zebra


#A /usr/local/include/quagga/*  -- ?



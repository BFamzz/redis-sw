FROM deb11-base:latest AS stageBuild
RUN git clone https://github.com/redis/hiredis.git && cd hiredis && make && make install \
    && git clone https://github.com/sewenew/redis-plus-plus.git && cd redis-plus-plus && mkdir build \
    && cd build && cmake -DREDIS_PLUS_PLUS_CXX_STANDARD=17 .. && make && make install && cd ..
WORKDIR /usr/src
COPY . .
RUN mkdir build
WORKDIR /usr/src/build
RUN cmake .. && make

FROM debian:latest
COPY --from=stageBuild /usr/src/build/redis-sw .
COPY --from=stageBuild /usr/local/lib /usr/lib
COPY --from=stageBuild /usr/lib/libacl_all.* /usr/lib
COPY --from=stageBuild /etc/ssl /etc/ssl
COPY --from=stageBuild /usr/lib/x86_64-linux-gnu/liboath.so.0 /usr/lib/x86_64-linux-gnu
COPY --from=stageBuild /usr/lib/x86_64-linux-gnu/libargon2.so.1 /usr/lib/x86_64-linux-gnu
COPY --from=stageBuild /usr/lib/x86_64-linux-gnu/libcurl.so.4 /usr/lib/x86_64-linux-gnu
COPY --from=stageBuild /usr/lib/x86_64-linux-gnu/libpq.so.5 /usr/lib/x86_64-linux-gnu
COPY --from=stageBuild /usr/lib/x86_64-linux-gnu/libldap_r-2.4.so.2 /usr/lib/x86_64-linux-gnu
COPY --from=stageBuild /usr/lib/x86_64-linux-gnu/liblber-2.4.so.2 /usr/lib/x86_64-linux-gnu
COPY --from=stageBuild /usr/lib/x86_64-linux-gnu/libsasl2.so.2 /usr/lib/x86_64-linux-gnu
COPY --from=stageBuild /usr/lib/x86_64-linux-gnu/libnghttp2.so.14 /usr/lib/x86_64-linux-gnu
COPY --from=stageBuild /usr/lib/x86_64-linux-gnu/librtmp.so.1 /usr/lib/x86_64-linux-gnu
COPY --from=stageBuild /usr/lib/x86_64-linux-gnu/libssh2.so.1 /usr/lib/x86_64-linux-gnu
COPY --from=stageBuild /usr/lib/x86_64-linux-gnu/libpsl.so.5 /usr/lib/x86_64-linux-gnu
COPY --from=stageBuild /usr/lib/x86_64-linux-gnu/libbrotlidec.so.1 /usr/lib/x86_64-linux-gnu
COPY --from=stageBuild /usr/lib/x86_64-linux-gnu/libbrotlicommon.so.1 /usr/lib/x86_64-linux-gnu
EXPOSE 8080
CMD ["./redis-sw"]
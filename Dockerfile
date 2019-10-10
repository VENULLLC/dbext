# Gateway Build Dependencies
FROM alpine:3.10
WORKDIR /dbext

RUN apk add --no-cache make gcc g++ wget sqlite-dev libstdc++ linux-headers 
COPY . .
RUN ls -la && CC=gcc make && cp build/dbext.so .

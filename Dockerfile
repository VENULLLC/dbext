# Gateway Build Dependencies
FROM python:2-alpine
WORKDIR /dbext

RUN apk add --no-cache make gcc g++ wget sqlite-dev libstdc++ linux-headers git && wget https://dl.bintray.com/boostorg/release/1.70.0/source/boost_1_70_0.tar.gz && tar xf boost_1_70_0.tar.gz && cd boost_1_70_0 && ./bootstrap.sh --prefix=/usr && ./b2 toolset=gcc cflags=-fPIC cxxflags=-fPIC variant=release runtime-link=static threading=multi --with-thread --with-system --with-date_time install && cd .. && wget https://www.sqlite.org/2019/sqlite-autoconf-3280000.tar.gz && tar xf sqlite-autoconf-3280000.tar.gz && cd sqlite-autoconf-3280000 && ./configure --prefix=/usr --disable-shared && make install

COPY . .
RUN ls -la && CC=gcc make && cp build/dbext.so .

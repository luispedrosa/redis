#!/bin/sh

set -ex

make distclean
rm -f redis-cli-dbg redis-server-dbg

make -kj`grep -c processor /proc/cpuinfo` \
  MALLOC=libc V=1 CFLAGS="-O0 -g"

gcc -Wall -O0 -g -o spa-client spa-client.c deps/hiredis/libhiredis.a

cp src/redis-cli redis-cli-dbg
cp src/redis-server redis-server-dbg

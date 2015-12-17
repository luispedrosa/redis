#!/bin/sh

set -ex

make distclean

make -kj`grep -c processor /proc/cpuinfo` \
  MALLOC=libc V=1 CFLAGS="-O0 -g"

gcc -Wall -O0 -g -o spa-client spa-client.c deps/hiredis/libhiredis.a

#!/bin/sh

set -ex

make distclean

make -kj`grep -c processor /proc/cpuinfo` \
  MALLOC=libc V=1 \
  CC="clang" LD="llvm-link" AR="true" RANLIB="true" \
  CFLAGS="-O0 -g -DENABLE_SPA -DENABLE_KLEE -emit-llvm" \
  LDFLAGS="-O0 -g -DENABLE_SPA -DENABLE_KLEE -emit-llvm" || true

llvm-link -o deps/lua/src/liblua.a \
  deps/lua/src/lapi.o \
  deps/lua/src/lcode.o \
  deps/lua/src/ldebug.o \
  deps/lua/src/ldo.o \
  deps/lua/src/ldump.o \
  deps/lua/src/lfunc.o \
  deps/lua/src/lgc.o \
  deps/lua/src/llex.o \
  deps/lua/src/lmem.o \
  deps/lua/src/lobject.o \
  deps/lua/src/lopcodes.o \
  deps/lua/src/lparser.o \
  deps/lua/src/lstate.o \
  deps/lua/src/lstring.o \
  deps/lua/src/ltable.o \
  deps/lua/src/ltm.o \
  deps/lua/src/lundump.o \
  deps/lua/src/lvm.o \
  deps/lua/src/lzio.o \
  deps/lua/src/strbuf.o \
  deps/lua/src/fpconv.o \
  deps/lua/src/lauxlib.o \
  deps/lua/src/lbaselib.o \
  deps/lua/src/ldblib.o \
  deps/lua/src/liolib.o \
  deps/lua/src/lmathlib.o \
  deps/lua/src/loslib.o \
  deps/lua/src/ltablib.o \
  deps/lua/src/lstrlib.o \
  deps/lua/src/loadlib.o \
  deps/lua/src/linit.o \
  deps/lua/src/lua_cjson.o \
  deps/lua/src/lua_struct.o \
  deps/lua/src/lua_cmsgpack.o \
  deps/lua/src/lua_bit.o

llvm-link -o deps/hiredis/libhiredis.a \
  deps/hiredis/net.o \
  deps/hiredis/hiredis.o \
  deps/hiredis/sds.o \
  deps/hiredis/async.o

make -kj`grep -c processor /proc/cpuinfo` \
  MALLOC=libc V=1 \
  CC="clang" LD="llvm-link" AR="true" RANLIB="true" \
  CFLAGS="-O0 -g -DENABLE_SPA -DENABLE_KLEE -emit-llvm" \
  LDFLAGS="-O0 -g -DENABLE_SPA -DENABLE_KLEE -emit-llvm" || true

llvm-link -o deps/hiredis/libhiredis.a \
  deps/hiredis/net.o \
  deps/hiredis/hiredis.o \
  deps/hiredis/async.o
#   deps/hiredis/sds.o \


make -kj`grep -c processor /proc/cpuinfo` \
  MALLOC=libc V=1 \
  CC="clang" LD="llvm-link" AR="true" RANLIB="true" \
  CFLAGS="-O0 -g -DENABLE_SPA -DENABLE_KLEE -emit-llvm" \
  LDFLAGS="-O0 -g -DENABLE_SPA -DENABLE_KLEE -emit-llvm" || true

llvm-link -o src/redis-cli \
  src/anet.o \
  src/adlist.o \
  src/redis-cli.o \
  src/zmalloc.o \
  src/release.o \
  src/ae.o \
  src/crc64.o \
  deps/hiredis/libhiredis.a \
  deps/linenoise/linenoise.o

llvm-link -o src/redis-server \
  src/adlist.o \
  src/quicklist.o \
  src/ae.o \
  src/anet.o \
  src/dict.o \
  src/server.o \
  src/sds.o \
  src/zmalloc.o \
  src/lzf_c.o \
  src/lzf_d.o \
  src/pqsort.o \
  src/zipmap.o \
  src/sha1.o \
  src/ziplist.o \
  src/release.o \
  src/networking.o \
  src/util.o \
  src/object.o \
  src/db.o \
  src/replication.o \
  src/rdb.o \
  src/t_string.o \
  src/t_list.o \
  src/t_set.o \
  src/t_zset.o \
  src/t_hash.o \
  src/config.o \
  src/aof.o \
  src/pubsub.o \
  src/multi.o \
  src/debug.o \
  src/sort.o \
  src/intset.o \
  src/syncio.o \
  src/cluster.o \
  src/crc16.o \
  src/endianconv.o \
  src/slowlog.o \
  src/scripting.o \
  src/bio.o \
  src/rio.o \
  src/rand.o \
  src/memtest.o \
  src/crc64.o \
  src/bitops.o \
  src/sentinel.o \
  src/notify.o \
  src/setproctitle.o \
  src/blocked.o \
  src/hyperloglog.o \
  src/latency.o \
  src/sparkline.o \
  src/redis-check-rdb.o \
  src/geo.o \
  src/lazyfree.o \
  deps/hiredis/libhiredis.a \
  deps/lua/src/liblua.a \
  deps/geohash-int/geohash.o \
  deps/geohash-int/geohash_helper.o

clang -Wall -O0 -g -DENABLE_SPA -DENABLE_KLEE -emit-llvm \
  -c -o spa-client.o \
  spa-client.c

llvm-link -o spa-client.bc \
  spa-client.o \
  src/sds.o src/zmalloc.o deps/hiredis/libhiredis.a

cp src/redis-server redis-server-llvm

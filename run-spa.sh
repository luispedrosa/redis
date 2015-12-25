#!/bin/bash

set -e

rm -f redis.paths

# gdb --args \
spa-explore \
    --in-paths redis.paths \
    --follow-in-paths \
    --out-paths redis.paths \
    --out-paths-append \
    --connect-sockets \
    --start-from spa_entry \
    --toward redis_done \
    --output-at spa_msg_no_input_point \
    --output-at redis_done \
    --participant redis-client \
    spa-client.bc \
    2>&1 | tee redis-client.log &

# gdb --args \
spa-explore \
    --in-paths redis.paths \
    --follow-in-paths \
    --out-paths redis.paths \
    --out-paths-append \
    --connect-sockets \
    --start-from spa_entry \
    --toward spa_msg_output_point \
    --use-shallow-distance \
    --output-at spa_msg_output_point \
    --participant redis-server \
    --dump-cov-on-interrupt redis-server.cov \
    src/redis-server \
    2>&1 | tee redis-server.log &
CLIENT_PID=$!

trap 'kill $(jobs -p)' EXIT

wait

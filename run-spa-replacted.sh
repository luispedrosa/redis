#!/bin/bash

set -e

rm -f redis-replicated.paths
rm -f dump.rdb

# gdb --args \
spa-explore \
    --in-paths redis-replicated.paths \
    --follow-in-paths \
    --out-paths redis-replicated.paths \
    --out-paths-append \
    --connect-sockets \
    --start-from spa_entry_masterslave \
    --toward redis_done \
    --stop-at redis_done \
    --output-at spa_msg_no_input_point \
    --output-at redis_done \
    --participant redis-client \
    --ip 127.0.0.1 \
    spa-client.bc \
    2>&1 | tee redis-client.log &

# gdb --args \
spa-explore \
    --in-paths redis-replicated.paths \
    --follow-in-paths \
    --out-paths redis-replicated.paths \
    --out-paths-append \
    --connect-sockets \
    --start-from spa_entry_master \
    --toward spa_msg_output_point \
    --stop-at redis_done \
    --use-shallow-distance \
    --output-at redis_done \
    --participant redis-master \
    --ip 127.0.0.2 \
    redis-server-llvm \
    2>&1 | tee redis-master.log &

# gdb --args \
spa-explore \
    --in-paths redis-replicated.paths \
    --follow-in-paths \
    --out-paths redis-replicated.paths \
    --out-paths-append \
    --connect-sockets \
    --start-from spa_entry_slave \
    --toward spa_msg_output_point \
    --stop-at redis_done \
    --use-shallow-distance \
    --output-at redis_done \
    --participant redis-slave \
    --ip 127.0.0.3 \
    redis-server-llvm \
    2>&1 | tee redis-slave.log &

trap 'kill $(jobs -p)' EXIT

wait

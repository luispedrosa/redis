#!/bin/bash

set -e

rm -f dump.rdb

parallel-conversational-analysis.sh redis-replicated.paths \
  "--shallow-exploration --connect-sockets --start-from spa_entry_masterslave --toward redis_done           --stop-at redis_done                        --output-at spa_msg_no_input_point --output-at redis_done --participant redis-client --ip 127.0.0.1 redis/spa-client.bc; \
   --shallow-exploration --connect-sockets --start-from spa_entry_master      --toward spa_msg_output_point --stop-at redis_done --use-shallow-distance --output-at redis_done                                    --participant redis-master --ip 127.0.0.2 redis/redis-server-llvm; \
   --shallow-exploration --connect-sockets --start-from spa_entry_slave       --toward spa_msg_output_point --stop-at redis_done --use-shallow-distance --output-at redis_done                                    --participant redis-slave  --ip 127.0.0.3 redis/redis-server-llvm" &

spa-explore-conversation \
    --connect-sockets \
    --participant-ip redis-client:127.0.0.1 \
    --participant-ip redis-master:127.0.0.2 \
    --participant-ip redis-slave:127.0.0.3 \
    --follow-in-paths \
    redis-replicated.paths \
    2>&1 | tee derived.log &

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

wait

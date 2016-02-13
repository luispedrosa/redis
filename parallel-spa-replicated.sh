#!/bin/bash

set -e

parallel-conversational-analysis.sh redis-replicated.paths \
  "--shallow-exploration --filter-input 'NOT REACHED redis_client_done' --connect-sockets --start-from spa_entry_masterslave --toward redis_client_done    --stop-at redis_client_done                        --output-at spa_msg_no_input_point --output-at redis_client_done --participant redis-client --ip 127.0.0.1 redis/spa-client.bc; \
   --shallow-exploration --filter-input 'NOT REACHED redis_client_done' --connect-sockets --start-from spa_entry_master      --toward spa_msg_output_point --stop-at redis_server_done --use-shallow-distance --output-at redis_server_done                                    --participant redis-master --ip 127.0.0.2 redis/redis-server-llvm; \
   --shallow-exploration --filter-input 'NOT REACHED redis_client_done' --connect-sockets --start-from spa_entry_slave       --toward spa_msg_output_point --stop-at redis_server_done --use-shallow-distance --output-at redis_server_done                                    --participant redis-slave  --ip 127.0.0.3 redis/redis-server-llvm" &

sleep 1

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

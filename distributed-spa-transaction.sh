#!/bin/bash

set -e

TARGET_CONVERSATION="redis-client1 redis-client2 redis-server redis-client1 redis-client2 redis-server redis-client1 redis-client2 redis-server redis-client1 redis-client2 redis-server redis-client1 redis-client2 redis-server"

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

distributed-conversational-analysis.sh redis-transaction.paths \
  "--shallow-exploration --filter-input \"NOT REACHED redis_client_done\" --connect-sockets --start-from spa_entry_transaction --toward redis_client_done    --stop-at redis_client_done                        --output-at spa_msg_output_point --output-at redis_client_done --participant redis-client1 --ip 127.0.0.1 redis/spa-client.bc; \
   --shallow-exploration --filter-input \"NOT REACHED redis_client_done\" --connect-sockets --start-from spa_entry_transaction --toward redis_client_done    --stop-at redis_client_done                        --output-at spa_msg_output_point --output-at redis_client_done --participant redis-client2 --ip 127.0.0.2 redis/spa-client.bc; \
   --shallow-exploration --filter-input \"NOT REACHED redis_client_done\" --connect-sockets --start-from spa_entry_master      --toward spa_msg_output_point --stop-at redis_server_done --use-shallow-distance --output-at spa_msg_output_point                               --participant redis-server  --ip 127.0.0.3 redis/redis-server-llvm" \
   "$TARGET_CONVERSATION" &
SPA_PID=$!

sleep 1

echo "Launching conversation exploration."
spa-explore-conversation \
    --connect-sockets \
    --participant-ip redis-client1:127.0.0.1 \
    --participant-ip redis-client2:127.0.0.2 \
    --participant-ip redis-server:127.0.0.3 \
    --follow-in-paths \
    redis-transaction.paths \
    >>redis-transaction.paths.log 2>&1 &

# echo "Follow analysis progress on: http://localhost:8000/"
spa-doc --serve-http 8000 \
        --map-src /home/lpedrosa/redis=/home/david/Projects/redis \
        --color-filter "lightgreen:REACHED redis_success" \
        --color-filter "orangered:REACHED redis_fail" \
        --color-filter "cyan:CONVERSATION $(echo $TARGET_CONVERSATION | sed 's/ *; */ OR CONVERSATION /')" \
        redis-transaction.paths

wait $SPA_PID
echo "Analysis is complete. Ctrl-C when ready."
wait

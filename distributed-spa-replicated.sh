#!/bin/bash

set -e

TARGET_CONVERSATION="redis-slave redis-master redis-slave redis-master redis-slave redis-master redis-slave redis-client redis-master redis-master redis-master redis-master redis-master redis-master redis-master redis-client redis-slave redis-slave redis-client; \
                     redis-client redis-slave redis-master redis-master redis-slave redis-master redis-slave redis-master redis-slave redis-master redis-master redis-master redis-master redis-master redis-client redis-slave redis-slave redis-client"

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

distributed-conversational-analysis.sh redis-replicated.paths \
  "--shallow-exploration --filter-input \"NOT REACHED redis_client_done\" --connect-sockets --start-from spa_entry_masterslave --toward redis_client_done    --stop-at redis_client_done                        --output-at spa_msg_output_point --output-at redis_client_done --participant redis-client --ip 127.0.0.1 redis/spa-client.bc; \
   --shallow-exploration --filter-input \"NOT REACHED redis_client_done\" --connect-sockets --start-from spa_entry_master      --toward spa_msg_output_point --stop-at redis_server_done --use-shallow-distance --output-at spa_msg_output_point                               --participant redis-master --ip 127.0.0.2 redis/redis-server-llvm; \
   --shallow-exploration --filter-input \"NOT REACHED redis_client_done\" --connect-sockets --start-from spa_entry_slave       --toward spa_msg_output_point --stop-at redis_server_done --use-shallow-distance --output-at spa_msg_output_point                               --participant redis-slave  --ip 127.0.0.3 redis/redis-server-llvm" \
   "$TARGET_CONVERSATION" &
SPA_PID=$!

sleep 1

echo "Launching conversation exploration."
spa-explore-conversation \
    --connect-sockets \
    --participant-ip redis-client:127.0.0.1 \
    --participant-ip redis-master:127.0.0.2 \
    --participant-ip redis-slave:127.0.0.3 \
    --follow-in-paths \
    redis-replicated.paths \
    >>redis-replicated.paths.log 2>&1 &

# echo "Follow analysis progress on: http://localhost:8000/"
# spa-doc --serve-http 8000 \
#         --map-src /home/lpedrosa/redis=/home/david/Projects/redis \
#         --color-filter "lightgreen:REACHED redis_success" \
#         --color-filter "orangered:REACHED redis_fail" \
#         --color-filter "cyan:CONVERSATION $(echo $TARGET_CONVERSATION | sed 's/ *; */ OR CONVERSATION /')" \
#         redis-replicated.paths

wait $SPA_PID
echo "Analysis is complete. Ctrl-C when ready."
wait

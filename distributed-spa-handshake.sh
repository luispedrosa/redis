#!/bin/bash

set -e

# TARGET_CONVERSATION="redis-slave redis-master redis-slave redis-master redis-slave redis-master redis-slave redis-master redis-master redis-master redis-master redis-master redis-master"
TARGET_CONVERSATION=""

FAULT_MODEL="onedrop"

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

distributed-conversational-analysis.sh redis-handshake.paths \
  "--shallow-exploration --fault-model $FAULT_MODEL --connect-sockets --start-from spa_entry_slave  --toward spa_msg_output_point --stop-at redis_server_done --use-shallow-distance --output-at spa_msg_output_point --participant redis-slave  --ip 127.0.0.1 redis/redis-server-llvm; \
   --shallow-exploration --fault-model $FAULT_MODEL --connect-sockets --start-from spa_entry_master --toward spa_msg_output_point --stop-at redis_server_done --use-shallow-distance --output-at spa_msg_output_point --participant redis-master --ip 127.0.0.2 redis/redis-server-llvm"
   "$TARGET_CONVERSATION" &
SPA_PID=$!

sleep 1

echo "Launching conversation exploration."
spa-explore-conversation \
    --connect-sockets \
    --participant-ip redis-slave:127.0.0.1 \
    --participant-ip redis-master:127.0.0.2 \
    --follow-in-paths \
    redis-handshake.paths \
    >>redis-handshake.paths.log 2>&1 &

# echo "Follow analysis progress on: http://localhost:8000/"
# spa-doc --serve-http 8000 \
#         --map-src /home/lpedrosa/redis=/home/david/Projects/redis \
#         --color-filter "cyan:CONVERSATION $(echo $TARGET_CONVERSATION | sed 's/ *; */ OR CONVERSATION /')" \
#         redis-handshake.paths

wait $SPA_PID
echo "Analysis is complete. Ctrl-C when ready."
wait

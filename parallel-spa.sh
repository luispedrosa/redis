#!/bin/bash

set -e

parallel-conversational-analysis.sh redis.paths \
  "--connect-sockets --start-from spa_entry --toward redis_done           --stop-at redis_done                                           --output-at spa_msg_no_input_point --output-at redis_done --participant redis-client --ip 127.0.0.1 redis/spa-client.bc; \
   --connect-sockets --start-from spa_entry --toward spa_msg_output_point --stop-at spa_msg_select_no_input_point --use-shallow-distance --output-at spa_msg_output_point                          --participant redis-server --ip 127.0.0.2 redis/redis-server-llvm"

trap 'kill $(jobs -p)' EXIT

wait

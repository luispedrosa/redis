#include <stdio.h>
#include <assert.h>

#include <spa/spaRuntime.h>

#include "deps/hiredis/hiredis.h"

void __attribute__((noinline, weak)) redis_done() {
  // Complicated NOP to prevent inlining.
  static int i = 0;
  i++;
}

void spa_entry() {
  char set_value[2] = "v";
  spa_api_input_var(set_value);
  set_value[sizeof(set_value) - 1] = '\0';

  redisContext *context = redisConnect("127.0.0.1", 6379);
  assert(context);

  redisReply *reply = redisCommand(context, "SET k %s", set_value);
  assert(reply && reply->type == REDIS_REPLY_STATUS);
#ifndef ENABLE_KLEE
  printf("%s\n", reply->str);
#endif
  freeReplyObject(reply);

  reply = redisCommand(context, "GET k");
  assert(reply && reply->type == REDIS_REPLY_STRING);
#ifndef ENABLE_KLEE
  printf("%s\n", reply->str);
#endif

  assert(strcmp(set_value, reply->str) == 0);

  redis_done();

  freeReplyObject(reply);
  redisFree(context);
}

int main(int argc, char *argv[]) {
  spa_entry();
  return 0;
}

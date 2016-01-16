#include <stdio.h>
#include <assert.h>

#include <spa/spaRuntime.h>

#include "deps/hiredis/hiredis.h"

void __attribute__((noinline, weak)) redis_sucess() {
  // Complicated NOP to prevent inlining.
  static int i = 0;
  i++;
}

void __attribute__((noinline, weak)) redis_fail() {
  // Complicated NOP to prevent inlining.
  static int i = 0;
  i++;
}

void __attribute__((noinline, weak)) redis_done() {
  // Complicated NOP to prevent inlining.
  static int i = 0;
  i++;
}

void spa_entry_single() {
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

  if (strcmp(set_value, reply->str) == 0) {
    redis_sucess();
  } else {
    redis_fail();
  }
  redis_done();

  freeReplyObject(reply);
  redisFree(context);
}

void spa_entry_masterslave() {
  char set_value[2] = "v";
  spa_api_input_var(set_value);
  set_value[sizeof(set_value) - 1] = '\0';

  redisContext *masterContext = redisConnect("127.0.0.1", 6379);
  assert(masterContext);

  redisReply *reply = redisCommand(masterContext, "SET k %s", set_value);
  assert(reply && reply->type == REDIS_REPLY_STATUS);
#ifndef ENABLE_KLEE
  printf("%s\n", reply->str);
#endif
  freeReplyObject(reply);
  redisFree(masterContext);

  redisContext *slaveContext = redisConnect("127.0.0.1", 6380);
  assert(slaveContext);

  reply = redisCommand(slaveContext, "GET k");
  assert(reply && reply->type == REDIS_REPLY_STRING);
#ifndef ENABLE_KLEE
  printf("%s\n", reply->str);
#endif

  if (strcmp(set_value, reply->str) == 0) {
    redis_sucess();
  } else {
    redis_fail();
  }
  redis_done();

  freeReplyObject(reply);
  redisFree(slaveContext);
}

int main(int argc, char *argv[]) {
  spa_entry_masterslave();
  return 0;
}

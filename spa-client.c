#include <stdio.h>
#include <assert.h>

#include <spa/spaRuntime.h>

#include "deps/hiredis/hiredis.h"

void __attribute__((noinline, weak)) redis_success() {
  // Complicated NOP to prevent inlining.
  static int i = 0;
  i++;
}

void __attribute__((noinline, weak)) redis_fail() {
  // Complicated NOP to prevent inlining.
  static int i = 0;
  i++;
}

void __attribute__((noinline, weak)) redis_client_done() {
  // Complicated NOP to prevent inlining.
  static int i = 0;
  i++;
}

void spa_entry_single() {
  char set_value[2] = "v";
  spa_api_input_var(set_value);
  set_value[sizeof(set_value) - 1] = '\0';

  redisContext *context = redisConnect("127.0.0.2", 6379);
  assert(context);

  redisReply *reply = redisCommand(context, "SET k %s", set_value);
  assert(reply && reply->type == REDIS_REPLY_STATUS);
#ifndef ENABLE_KLEE
  printf("%s\n", reply->str);
#endif
  freeReplyObject(reply);

  reply = redisCommand(context, "GET k");
  assert(reply &&
         (reply->type == REDIS_REPLY_STRING || reply->type == REDIS_REPLY_NIL));
#ifndef ENABLE_KLEE
  printf("%s\n", reply->type == REDIS_REPLY_STRING ? reply->str : "(nil)");
#endif

  if (reply->type == REDIS_REPLY_STRING && strcmp(set_value, reply->str) == 0) {
    redis_success();
  } else {
    redis_fail();
  }
  redis_client_done();

  freeReplyObject(reply);
  redisFree(context);
}

void spa_entry_masterslave() {
  char set_value[2] = "v";
  spa_api_input_var(set_value);
  set_value[sizeof(set_value) - 1] = '\0';

  redisContext *masterContext = redisConnect("127.0.0.2", 6379);
  assert(masterContext);

  redisReply *reply = redisCommand(masterContext, "SET k %s", set_value);
  assert(reply && reply->type == REDIS_REPLY_STATUS);
#ifndef ENABLE_KLEE
  printf("%s\n", reply->str);
#endif
  freeReplyObject(reply);
  redisFree(masterContext);

  redisContext *slaveContext = redisConnect("127.0.0.3", 6380);
  assert(slaveContext);

  reply = redisCommand(slaveContext, "GET k");
  assert(reply &&
         (reply->type == REDIS_REPLY_STRING || reply->type == REDIS_REPLY_NIL));
#ifndef ENABLE_KLEE
  printf("%s\n", reply->type == REDIS_REPLY_STRING ? reply->str : "(nil)");
#endif

  if (reply->type == REDIS_REPLY_STRING && strcmp(set_value, reply->str) == 0) {
    redis_success();
  } else {
    redis_fail();
  }
  redis_client_done();

  freeReplyObject(reply);
  redisFree(slaveContext);
}

void spa_entry_multiserver() {
  char set_key[2] = "k";
  spa_api_input_var(set_key);
  set_key[sizeof(set_key) - 1] = '\0';

  char set_value[2] = "v";
  spa_api_input_var(set_value);
  set_value[sizeof(set_value) - 1] = '\0';

  redisContext *masterAContext = redisConnect("127.0.0.2", 6379);
  assert(masterAContext);

  redisReply *reply = redisCommand(masterAContext, "SET k a");
  assert(reply && reply->type == REDIS_REPLY_STATUS);
#ifndef ENABLE_KLEE
  printf("%s\n", reply->str);
#endif
  freeReplyObject(reply);
  redisFree(masterAContext);

  redisContext *masterBContext = redisConnect("127.0.0.3", 6380);
  assert(masterBContext);

  reply = redisCommand(masterBContext, "SET k b");
  assert(reply && reply->type == REDIS_REPLY_STATUS);
#ifndef ENABLE_KLEE
  printf("%s\n", reply->str);
#endif
  freeReplyObject(reply);
  redisFree(masterBContext);

  redisContext *slaveAContext = redisConnect("127.0.0.4", 6381);
  assert(slaveAContext);

  reply = redisCommand(slaveAContext, "SLAVEOF 127.0.0.2 6379");
  assert(reply && reply->type == REDIS_REPLY_STATUS);
#ifndef ENABLE_KLEE
  printf("%s\n", reply->str);
#endif
  freeReplyObject(reply);

  redisContext *slaveBContext = redisConnect("127.0.0.5", 6382);
  assert(slaveBContext);

  reply = redisCommand(slaveBContext, "SLAVEOF 127.0.0.4 6381");
  assert(reply && reply->type == REDIS_REPLY_STATUS);
#ifndef ENABLE_KLEE
  printf("%s\n", reply->str);
#endif
  freeReplyObject(reply);

#ifndef ENABLE_KLEE
  sleep(5);
#endif

  reply = redisCommand(slaveAContext, "GET k");
  assert(reply &&
         (reply->type == REDIS_REPLY_STRING || reply->type == REDIS_REPLY_NIL));
#ifndef ENABLE_KLEE
  printf("%s\n", reply->type == REDIS_REPLY_STRING ? reply->str : "(nil)");
#endif
  assert(reply->type == REDIS_REPLY_STRING && strcmp("a", reply->str) == 0);
  freeReplyObject(reply);

  reply = redisCommand(slaveBContext, "GET k");
  assert(reply &&
         (reply->type == REDIS_REPLY_STRING || reply->type == REDIS_REPLY_NIL));
#ifndef ENABLE_KLEE
  printf("%s\n", reply->type == REDIS_REPLY_STRING ? reply->str : "(nil)");
#endif
  assert(reply->type == REDIS_REPLY_STRING && strcmp("a", reply->str) == 0);
  freeReplyObject(reply);

  reply = redisCommand(slaveAContext, "SLAVEOF 127.0.0.3 6380");
  assert(reply && reply->type == REDIS_REPLY_STATUS);
#ifndef ENABLE_KLEE
  printf("%s\n", reply->str);
#endif
  freeReplyObject(reply);

#ifndef ENABLE_KLEE
  sleep(5);
#endif

  reply = redisCommand(slaveAContext, "GET k");
  assert(reply &&
         (reply->type == REDIS_REPLY_STRING || reply->type == REDIS_REPLY_NIL));
#ifndef ENABLE_KLEE
  printf("%s\n", reply->type == REDIS_REPLY_STRING ? reply->str : "(nil)");
#endif
  assert(reply->type == REDIS_REPLY_STRING && strcmp("b", reply->str) == 0);
  freeReplyObject(reply);

  reply = redisCommand(slaveBContext, "GET k");
  assert(reply &&
         (reply->type == REDIS_REPLY_STRING || reply->type == REDIS_REPLY_NIL));
#ifndef ENABLE_KLEE
  printf("%s\n", reply->type == REDIS_REPLY_STRING ? reply->str : "(nil)");
#endif
  assert(reply->type == REDIS_REPLY_STRING && strcmp("b", reply->str) == 0);
  freeReplyObject(reply);

  redisFree(slaveAContext);
  redisFree(slaveBContext);

  //   if (reply->type == REDIS_REPLY_STRING && strcmp(set_value, reply->str) ==
  // 0) {
  //     redis_success();
  //   } else {
  //     redis_fail();
  //   }
  redis_client_done();
}

void spa_entry_transaction() {
  char set_value[2] = "v";

  redisContext *masterContext = redisConnect("127.0.0.2", 6379);
  assert(masterContext);

  int succeeded;
  do {
    redisReply *reply = redisCommand(masterContext, "WATCH k");
    assert(reply && reply->type == REDIS_REPLY_STATUS);
#ifndef ENABLE_KLEE
    printf("%s\n", reply->str);
#endif
    freeReplyObject(reply);

    reply = redisCommand(masterContext, "GET k");
    assert(reply && (reply->type == REDIS_REPLY_STRING ||
                     reply->type == REDIS_REPLY_NIL));
#ifndef ENABLE_KLEE
    printf("%s\n", reply->type == REDIS_REPLY_STRING ? reply->str : "(nil)");
#endif
    if (reply->type == REDIS_REPLY_STRING) {
      strncpy(set_value, reply->str, sizeof(set_value));
    } else {
      set_value[0] = '0';
    }
    freeReplyObject(reply);

    set_value[0]++;

    reply = redisCommand(masterContext, "MULTI");
    assert(reply && reply->type == REDIS_REPLY_STATUS);
#ifndef ENABLE_KLEE
    printf("%s\n", reply->str);
#endif
    freeReplyObject(reply);

    reply = redisCommand(masterContext, "SET k %s", set_value);
    assert(reply && reply->type == REDIS_REPLY_STATUS);
#ifndef ENABLE_KLEE
    printf("%s\n", reply->str);
#endif
    freeReplyObject(reply);

    reply = redisCommand(masterContext, "EXEC");
    assert(reply);
#ifndef ENABLE_KLEE
    if (reply->type == REDIS_REPLY_NIL) {
      printf("Transaction aborted.\n");
    } else if (reply->type == REDIS_REPLY_ARRAY) {
      printf("Transaction committed.\n");
      int i;
      for (i = 0; i < reply->elements; i++) {
        printf("Result: %s\n", reply->element[i]->str);
      }
    } else {
      assert(0 && "Unknown response type.");
    }
#endif
    succeeded = reply->type == REDIS_REPLY_ARRAY;
    freeReplyObject(reply);
  } while (!succeeded);

  redisReply *reply = redisCommand(masterContext, "GET k");
  assert(reply && reply->type == REDIS_REPLY_STRING);
#ifndef ENABLE_KLEE
  printf("%s\n", reply->type == REDIS_REPLY_STRING ? reply->str : "(nil)");
#endif
  if (strcmp("2", reply->str) == 0) {
    redis_success();
  } else {
    redis_fail();
  }
  freeReplyObject(reply);

  redisFree(masterContext);

  redis_client_done();
}

int main(int argc, char *argv[]) {
  spa_entry_transaction();
  return 0;
}

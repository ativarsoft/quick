#include <templatizer.h>
#include <templatizer/compiler/compiler.h>
#include <threads.h>
#include <stdio.h>
#include <stdint.h>
#include <assert.h>
#include <lmdb.h>
#include <unistd.h>
#include <sys/types.h>
#include <pwd.h>

void adainit();
void adafinal();
void Davinit();
void initialize_dav();
void finalize_dav();

thread_local tmpl_ctx_t dav_ctx;
thread_local struct templatizer_callbacks *dav_cb;

const char *tmpl_get_script_path()
{
    TMPL_ASSERT(dav_ctx);
    return dav_ctx->script_path;
}

const char *tmpl_get_path_info()
{
    TMPL_ASSERT(dav_ctx);
    return dav_ctx->path_info;
}

void tmpl_send_default_headers()
{
    dav_cb->send_default_headers(dav_ctx);
}

void tmpl_filler_text(const char *s)
{
    dav_cb->add_filler_text(dav_ctx, s);
}

void tmpl_if(int a)
{
    dav_cb->add_control_flow(dav_ctx, a? IF_TRUE : IF_FALSE);
}

void tmpl_swhile(int a)
{
    dav_cb->add_control_flow(dav_ctx, a? SWHILE_TRUE : SWHILE_FALSE);
}

static int init(tmpl_ctx_t data, struct templatizer_callbacks *cb)
{
    //adainit();
    //Davinit();
    dav_ctx = data;
    dav_cb = cb;
    initialize_dav();
    return 0;
}

static void quit()
{
    finalize_dav();
    //adafinal();
}

struct templatizer_plugin templatizer_plugin_v1 = {
    &init,
    &quit
};

typedef MDB_txn *tmpl_txn_t;
typedef MDB_dbi tmpl_dbi_t;

MDB_env *env = NULL;

const char *homedir()
{
  struct passwd *pw = getpwuid(getuid());

  return pw->pw_dir;
}

int storage_open(const char *path)
{
  int rc;
  rc = mdb_env_open(env, path, 0, 0664);
  if (rc)
    return 1;
  return 0;
}

int storage_initialize()
{
  int rc;

  assert(env == NULL);
  rc = mdb_env_create(&env);
  if (rc)
    return 1;
  return 0;
}

int storage_finalize()
{
  assert(env != NULL);
  mdb_env_close(env);
  return 0;
}

int storage_begin_transaction(uintptr_t *txn)
{
  int rc;
  assert(env != NULL);
  rc = mdb_txn_begin(env, NULL, 0, txn);
  return rc;
}

int storage_commit_transaction(uintptr_t txn)
{
  assert(env != NULL);
  return 0;
}

int storage_abort_transaction(uintptr_t txn)
{
  assert(env != NULL);
  mdb_txn_abort(txn);
  return 0;
}

int storage_open_table(tmpl_txn_t txn, tmpl_dbi_t *dbi)
{
  int rc;
  assert(env != NULL);
  rc = mdb_open(txn, NULL, 0, dbi);
  return rc;
}

int storage_close_table(tmpl_dbi_t dbi)
{
  assert(env != NULL);
  mdb_close(env, dbi);
  return 0;
}

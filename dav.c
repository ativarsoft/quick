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
#include <stdbool.h>

void adainit();
void adafinal();
void Davinit();
void initialize_dav();
void finalize_dav();

static thread_local tmpl_ctx_t dav_ctx;
static thread_local struct templatizer_callbacks *dav_cb;
static thread_local bool headers_sent = false;

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

void tmpl_set_output_format_plain_text()
{
    dav_cb->set_output_format(dav_ctx, TMPL_FMT_HTML);
}

void tmpl_send_default_headers()
{
    if (!headers_sent) {
        headers_sent = true;
        dav_cb->send_default_headers(dav_ctx);
    }
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
  return rc != MDB_SUCCESS;
}

int storage_initialize()
{
  int rc;

  assert(env == NULL);
  rc = mdb_env_create(&env);
  return rc != MDB_SUCCESS;
}

int storage_finalize()
{
  assert(env != NULL);
  mdb_env_close(env);
  return 0;
}

int storage_begin_transaction(tmpl_txn_t *txn)
{
  int rc;
  assert(env != NULL);
  rc = mdb_txn_begin(env, NULL, 0, txn);
  return rc != MDB_SUCCESS;
}

int storage_commit_transaction(tmpl_txn_t txn)
{
  int rc;
  assert(env != NULL);
  rc = mdb_txn_commit(txn);
  return rc != MDB_SUCCESS;
}

int storage_abort_transaction(tmpl_txn_t txn)
{
  assert(env != NULL);
  mdb_txn_abort(txn);
  return 0;
}

int storage_open_database(tmpl_txn_t txn, tmpl_dbi_t *dbi)
{
  int rc;
  assert(env != NULL);
  rc = mdb_open(txn, NULL, 0, dbi);
  return rc != MDB_SUCCESS;
}

int storage_close_database(tmpl_dbi_t dbi)
{
  assert(env != NULL);
  mdb_close(env, dbi);
  return 0;
}

int storage_get_string(tmpl_txn_t txn, tmpl_dbi_t dbi, int key_id, char **value)
{
  int rc;
  MDB_val key, data;
  memset(&key, 0, sizeof(key));
  memset(&data, 0, sizeof(data));
  key.mv_size = sizeof(key_id);
  key.mv_data = &key_id;
  rc = mdb_get(txn, dbi, &key, &data);
  if (rc == 0) {
    *value = strndup((const char *) data.mv_data, data.mv_size);
  } else {
    *value = NULL;
  }
  return rc;
}

int storage_get_integer(tmpl_txn_t txn, tmpl_dbi_t dbi, int key_id, int *value)
{
  int rc;
  MDB_val key, data;
  memset(&key, 0, sizeof(key));
  memset(&data, 0, sizeof(data));
  key.mv_size = sizeof(key_id);
  key.mv_data = &key_id;
  rc = mdb_get(txn, dbi, &key, &data);
  if (rc == 0) {
    *value = *((int *) data.mv_data);
  } else {
    *value = 0;
  }
  return rc;
}

int storage_put_string(tmpl_txn_t txn, tmpl_dbi_t dbi, int key_id, const char *value, int length)
{
    int rc;
    MDB_val key, data;
    assert(txn);
    assert(dbi);
    memset(&key, 0, sizeof(key));
    memset(&data, 0, sizeof(data));
    key.mv_size = sizeof(key_id);
    key.mv_data = &key_id;
    data.mv_size = strnlen(value, length);
    data.mv_data = strndup(value, length);
    rc = mdb_put(txn, dbi, &key, &data, 0);
    rc = 0;
    return rc;
}

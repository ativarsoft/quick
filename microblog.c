#include <templatizer.h>
#include <gio/gio.h>
#include <sys/types.h>
#include <dirent.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <lmdb.h>
#include <pwd.h>

typedef MDB_txn *tmpl_txn_t;
typedef MDB_dbi tmpl_dbi_t;

MDB_env *env;

static int storage_init()
{
  int rc;
  MDB_dbi dbi;
  MDB_val key, data;

  struct passwd *pw = getpwuid(getuid());

  const char *homedir = pw->pw_dir;

  rc = mdb_env_create(&env);
  if (rc)
    return 1;
  rc = mdb_env_open(env, "", 0, 0664);
  if (rc)
    return 1;
  return 0;
}

static int storage_quit()
{
  mdb_env_close(env);
  return 0;
}

static int storage_begin_transaction(tmpl_txn_t *txn)
{
  int rc;
  rc = mdb_txn_begin(env, NULL, 0, txn);
  return rc;
}

static int storage_commit_transaction()
{
  return 0;
}

static int storage_abort_transaction(tmpl_txn_t txn)
{
  mdb_txn_abort(txn);
  return 0;
}

static int storage_open_table(tmpl_txn_t txn, tmpl_dbi_t *dbi)
{
  int rc;
  rc = mdb_open(txn, NULL, 0, dbi);
  return rc;
}

static int storage_close_table(tmpl_dbi_t dbi)
{
  mdb_close(env, dbi);
  return 0;
}

static int insert_post(char *post)
{
  tmpl_txn_t txn;
  tmpl_dbi_t dbi;
  storage_begin_transaction(&txn);
  storage_open_table(txn, &dbi);
  storage_close_table(dbi);
  return 0;
}

static int list_posts(tmpl_ctx_t data, struct templatizer_callbacks *cb)
{
  cb->add_control_flow(data, SWHILE_TRUE);
  cb->add_filler_text(data, "Hello world!");
  cb->add_filler_text(data, "Mateus");
  cb->add_filler_text(data, "2022-11-01 13:50");

  /* tags */
  cb->add_control_flow(data, SWHILE_FALSE);

  cb->add_control_flow(data, SWHILE_FALSE);
  return 0;
}

static int init(struct context *data, struct templatizer_callbacks *cb)
{
	char *method = getenv("REQUEST_METHOD");
	TMPL_ASSERT(method != NULL);

	storage_init();
	list_posts(data, cb);
	cb->set_output_format(data, TMPL_FMT_HTML);
	cb->send_default_headers(data);
	puts("<!DOCTYPE html>");
	return 0;
}

static void quit()
{
  storage_quit();
}

struct templatizer_plugin templatizer_plugin_v1 = {
	&init,
	&quit
};


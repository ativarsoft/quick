import templatizer;

extern(C) char *strndup(const(char) *s, size_t len);

void tmpl_assert(int condition, string message)
{
    import core.stdc.stdio : fputs, stderr;
    import core.stdc.stdlib : free;
    if (condition) return;
    const(char) *s = strndup(message.ptr, message.length);
    fputs(s, stderr);
    free(cast(void *) s);
    assert(0);
}

extern(C)
static int init(tmpl_ctx_t data, tmpl_cb_t cb)
{
    tmpl_dbi_t dbi;
    tmpl_txn_t txn;
    int rc = -1;
    string text, author, datetime;
    rc = storage_initialize_thread(data, cb);
    tmpl_assert(rc == 0, "failed to initialize storage thread");
    rc = storage_open("/var/www/templatizer");
    tmpl_assert(rc == 0, "failed to open database environment");
    txn = null;
    rc = storage_begin_transaction(txn);
    tmpl_assert(rc == 0, "failed to create transaction");
    dbi = 0;
    rc = storage_open_database(txn, dbi);
    tmpl_assert(rc == 0, "failed to open database");
    rc = storage_get_string(txn, dbi, 1, text);
    tmpl_assert(rc == 0, "failed to get post text storage string");
    rc = storage_get_string(txn, dbi, 2, author);
    tmpl_assert(rc == 0, "failed to get post author storage string");
    rc = storage_get_string(txn, dbi, 3, datetime);
    tmpl_assert(rc == 0, "failed to get post date and time storage string");
    rc = cb.storage_commit_transaction(txn);
    tmpl_assert(rc == 0, "failed to commit transaction");
    cb.add_control_flow(data, SWHILE_TRUE);
    cb.add_filler_text(data, "Hello world!", 0);
    cb.add_filler_text(data, "Mateus", 0);
    cb.add_filler_text(data, "2022-11-24", 0);
    cb.add_control_flow(data, SWHILE_FALSE);
    cb.add_control_flow(data, SWHILE_FALSE);
    cb.storage_close_database(dbi);
    rc = storage_finalize_thread();
    tmpl_assert(rc == 0, "failed to finalize storage thread");
    cb.send_default_headers(data);
    return 0;
}

extern(C) static void quit() {}

extern(C)
__gshared
immutable(templatizer_plugin)
templatizer_plugin_v1 = {
        &init,
        &quit
};

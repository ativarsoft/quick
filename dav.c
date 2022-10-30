#include <templatizer.h>
#include <threads.h>

void adainit();
void adafinal();
void initialize_dav();
void finalize_dav();

thread_local tmpl_ctx_t dav_ctx;
thread_local struct templatizer_callbacks *dav_cb;

void dav_send_default_headers()
{
    dav_cb->send_default_headers(dav_ctx);
}

void dav_filler_text(const char *s)
{
    dav_cb->add_filler_text(dav_ctx, s);
}

void dav_if(int a)
{
    dav_cb->add_control_flow(dav_ctx, a? IF_TRUE : IF_FALSE);
}

void dav_swhile(int a)
{
    dav_cb->add_control_flow(dav_ctx, a? SWHILE_TRUE : SWHILE_FALSE);
}

static int init(tmpl_ctx_t *data, struct templatizer_callbacks *cb)
{
    //adainit();
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

import templatizer;

extern(C)
static int init(tmpl_ctx_t data, tmpl_cb_t cb)
{
    cb.add_control_flow(data, SWHILE_TRUE);
    cb.add_filler_text(data, "Hello world!");
    cb.add_filler_text(data, "Mateus");
    cb.add_filler_text(data, "2022-11-24");
    cb.add_control_flow(data, SWHILE_FALSE);
    cb.add_control_flow(data, SWHILE_FALSE);
    return 0;
}

extern(C) static void quit() {}

extern(C)
templatizer_plugin templatizer_plugin_v1 = {
        &init,
        &quit
};

#include <templatizer.h>
#include <csv.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>

#include <libintl.h>
#include <locale.h>

#include <GeoIP.h>
#include <netdb.h>
#include <templatizer.h>
#include <templatizer/query.h>

struct query_context
{
    tmpl_ctx_t tmpl;
    struct templatizer_callbacks *cb;
    char *s;
};

int inetaddr(const char *name, char ipstr[INET_ADDRSTRLEN]) {
    struct hostent *host;
    struct in_addr inaddr;

    host = gethostbyname(name);
    if (host == NULL)
        return 1;
    inaddr.s_addr = *((uint32_t *)host->h_addr_list[0]);
    //inet_ntop(AF_INET, &(sa.sin_addr), str, INET_ADDRSTRLEN);
    inet_ntop(AF_INET, &inaddr, ipstr, INET_ADDRSTRLEN);
    return 0;
}

int handle_key_pair
    (void *data,
     void *key, size_t key_len,
     void *value, size_t value_len)
{
    struct query_context *ctx = (struct query_context *) data;
    //size_t len = value_len + 1;
    //ctx->s = ctx->cb->templatizer_malloc(ctx->tmpl, len);
    //memset(ctx->s, 0, len);
    if (strncmp(key, "dns-name", key_len) == 0)
	    ctx->s = strndup(value, value_len);
    return 0;
}

static int init(tmpl_ctx_t data, struct templatizer_callbacks *cb)
{
    const char *method = NULL;
    const char *input_dns_name_placeholder;
    const char *input_submit_value;

    char ipstr[INET_ADDRSTRLEN] = "";
    struct query_context query;

    query.tmpl = data;
    query.cb = cb;

    tmpl_parse_query_string_get(&query, &handle_key_pair);

    if (query.s)
	    inetaddr(query.s, ipstr);
    else
            query.s[0] = '\0';

    setlocale (LC_ALL, "");
    bindtextdomain ("nslookup", "/home/mateus/dev/c/quick/");
    textdomain ("nslookup");
    input_dns_name_placeholder =
        gettext("e.g. ativarsoft.com.br");
    input_submit_value =
        gettext("Resolve");

    method = getenv("REQUEST_METHOD");
    TMPL_ASSERT(method != NULL);
    if (strcmp(method, "GET") == 0) {
        cb->add_filler_text(data, input_dns_name_placeholder);
        cb->add_filler_text(data, input_submit_value);
        cb->add_filler_text(data, ipstr);
    } else if (strcmp(method, "POST") == 0) {
    } else {
        fputs("Status: 404 Not found\r\n"
              "Content-Type: text/plain\r\n"
              "\r\n"
              "Page not found.",
              stdout);
        return 0;
    }

    cb->set_output_format(data, TMPL_FMT_HTML);
    cb->send_default_headers(data);
    puts("<!DOCTYPE html>");
    return 0;
}

static void quit() {}

struct templatizer_plugin templatizer_plugin_v1 = {
    &init,
    &quit
};

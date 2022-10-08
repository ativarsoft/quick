#include <templatizer.h>
#include <csv.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>

struct csv_parser_context {
    long unsigned fields;
    long unsigned rows;
    struct context *data;
    struct templatizer_callbacks *cb;
};

/*static void print_html_escaped(char *s, size_t len)
{
    int i;
    char c;
    for (i = 0; i < len; i++) {
        c = s[i];
        switch (c) {
            case '\"': puts("&quot");   //quotation mark
            case '\'': puts("&apos");    //apostrophe 
            case '&':  puts("&amp");    //ampersand
            case '<':  puts("&lt");     //less-than
            case '>':  puts("&gt");      //greater-than
            default:
            putchar(c);
        }
    }
}*/

void cb1 (void *s, size_t len, void *data) {
    struct csv_parser_context *ctx = (struct csv_parser_context *) data;
    char *dup;

    //((struct counts *)data)->fields++;

    // this should go into templatizer
    //print_html_escaped(s, len);

    dup = strndup(s, len);
    ctx->cb->add_filler_text(ctx->data, dup);
    free(dup);
}

void cb2 (int c, void *data) {
    //((struct counts *)data)->rows++;
    //struct csv_parser_context *ctx = (struct csv_parser_context *) data;
    //ctx->cb->add_control_flow(ctx->data, SWHILE_TRUE);
}

static int read_csv(struct csv_parser_context *c, char *path)
{
    FILE *fp;
    struct csv_parser p;
    char buf[1024];
    size_t bytes_read, bytes_parsed;
    char *errormsg;

    if (csv_init(&p, 0) != 0) return 1;
    fp = fopen(path, "rb");
    if (!fp) return 2;;

    while ((bytes_read=fread(buf, 1, 1024, fp)) > 0) {
        bytes_parsed = csv_parse(&p, buf, bytes_read, cb1, cb2, c);
        if (bytes_parsed != bytes_read) {
            errormsg = csv_strerror(csv_error(&p));
            fprintf(stderr, "Error while parsing file: %s\n",
                errormsg);
            return 3;
        }
    }

    csv_fini(&p, cb1, cb2, &c);

    fclose(fp);
    //printf("%lu fields, %lu rows\n", c->fields, c->rows);
    csv_free(&p);

    return 0;
}

static int get_bank_statement
    (struct context *data,
     struct templatizer_callbacks *cb,
     char *username,
     char *filename)
{
    struct csv_parser_context *ctx = NULL;
    const char fmt[] = "/var/mateus/quick/%s/%s";
    char *path = NULL;
    int result = -1;
    size_t len;

    //cb->add_control_flow(data, SWHILE_TRUE);
    ctx = cb->malloc(data, sizeof(*ctx));
    memset(ctx, 0, sizeof(*ctx));
    ctx->data = data;
    ctx->cb = cb;
    len = snprintf(NULL, 0, fmt, username, filename);
    len++;
    path = cb->malloc(data, len);
    snprintf(path, len, fmt, username, filename);
    fprintf(stderr, "CSV path: %s\n", path);
    result = read_csv(ctx, path);
    cb->free(data, path);
    cb->free(data, ctx);
    //cb->add_control_flow(data, SWHILE_FALSE);
    return result;
}

static int post_bank_statement
    (struct context *data,
     struct templatizer_callbacks *cb)
{
    return 0;
}

static int init(struct context *data, struct templatizer_callbacks *cb)
{
    const char *method = NULL;
    int page_aborted = 0;

    method = getenv("REQUEST_METHOD");
    TMPL_ASSERT(method != NULL);
    if (strcmp(method, "GET") == 0) {
        TMPL_ASSERT(get_bank_statement(data, cb, "mateus", "test.csv") == 0);
    } else if (strcmp(method, "POST") == 0) {
        TMPL_ASSERT(post_bank_statement(data, cb) == 0);
    } else {
        fputs("Status: 404 Not found\r\n"
              "Content-Type: text/plain\r\n"
              "\r\n"
              "Page not found.",
              stdout);
        page_aborted = 1;
    }

    if (page_aborted == 0) {
        cb->set_output_format(data, TMPL_FMT_HTML);
        cb->send_default_headers(data);
        puts("<!DOCTYPE html>");
    }
    return 0;
}

static void quit() {}

struct templatizer_plugin templatizer_plugin_v1 = {
    &init,
    &quit
};

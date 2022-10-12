#include <templatizer.h>
#include <csv.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>

#include <libintl.h>
#include <locale.h>

#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
#include <templatizer.h>
#include <templatizer/query.h>

typedef struct query_context
{
    tmpl_ctx_t tmpl;
    struct templatizer_callbacks *cb;
    char *input_format;
    char *output_format;
} *query_context_t;

/*
 * Functions for interfacing with FFmpeg
 */

void initialize_ffmpeg(tmpl_ctx_t data, struct templatizer_callbacks *cb)
{
    const AVInputFormat *av_in = NULL;
    void *av_ctx = NULL;
    const char *p;

    while((av_in = av_demuxer_iterate(&av_ctx)) != NULL) {
        cb->add_control_flow(data, SWHILE_TRUE);
        p = av_in->name;
        cb->add_filler_text(data, p? p : "");
        p = av_in->long_name;
        cb->add_filler_text(data, p? p : "");
        p = av_in->extensions;
        cb->add_filler_text(data, p? p : "");
    }
    cb->add_control_flow(data, SWHILE_FALSE);
    avformat_network_init();
}

/*
 * Entry points
 */

int handle_key_pair
    (void *data,
     void *key, size_t key_len,
     void *value, size_t value_len)
{
    struct query_context *ctx = (struct query_context *) data;
    //size_t len = value_len + 1;
    //ctx->s = ctx->cb->templatizer_malloc(ctx->tmpl, len);
    //memset(ctx->s, 0, len);
    if (strncmp(key, "input-format", key_len) == 0)
	    ctx->input_format = strndup(value, value_len);
    if (strncmp(key, "output-format", key_len) == 0)
	    ctx->output_format = strndup(value, value_len);
    return 0;
}

static int init(tmpl_ctx_t data, struct templatizer_callbacks *cb)
{
    const char *method = NULL;
    const char *text_audio_format = "";
    const char *text_video_format = "";
    const char *media_audio_format = "";
    const char *media_video_format = "";
    query_context_t query = NULL;

    query = cb->malloc(data, sizeof(*query));
    query->tmpl = data;
    query->cb = cb;

    tmpl_parse_query_string_get(query, handle_key_pair);

    setlocale (LC_ALL, "");
    bindtextdomain ("quick-transcode", "/usr/share/local/");
    textdomain ("quick-transcode");
    text_audio_format =
        gettext("Audio format");
    text_video_format =
        gettext("Video format");

    method = getenv("REQUEST_METHOD");
    TMPL_ASSERT(method != NULL);
    if (strcmp(method, "GET") == 0) {
        cb->add_filler_text(data, text_audio_format);
        cb->add_filler_text(data, media_audio_format);
        cb->add_filler_text(data, text_video_format);
        cb->add_filler_text(data, media_video_format);
        /* Does FFmpeg use gettext? If so, this should come after
         * gettext initialization. */
        initialize_ffmpeg(data, cb);
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
    cb->free(data, query);
    return 0;
}

static void quit() {}

struct templatizer_plugin templatizer_plugin_v1 = {
    &init,
    &quit
};

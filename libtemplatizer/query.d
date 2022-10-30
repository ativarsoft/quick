/* Copyright (C) 2022 Mateus de Lima Oliveira */

module libtemplatizer.query;

extern(C) {

alias http_query_callback_t =
int function
    (void *data,
     void *key, size_t key_len,
     void *value, size_t value_len);

alias tmpl_parse_query_string =
void function
    (char *query, void *data,
     http_query_callback_t cb);

int tmpl_parse_query_string_get(void *data, http_query_callback_t cb);
int tmpl_parse_query_string_post(void *data, http_query_callback_t cb);

}

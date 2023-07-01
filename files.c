#include <templatizer.h>
#include <gio/gio.h>
#include <sys/types.h>
#include <dirent.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

static int get_file_info(const char *filename, const char **description, const char **mime, const char **executable)
{
    char *desc;

    *description = NULL;
    *mime = NULL;
    *executable = NULL;
    //g_thread_init (NULL);

    if (filename == NULL) {
        return -1;
    }

    //g_type_init ();

    GError *error;
    GFile *file = g_file_new_for_path (filename);
    if (file == NULL)
        return 1;
    GFileInfo *file_info = g_file_query_info (file,
                                              "standard::*",
                                              0,
                                              NULL,
                                              &error);
    if (file_info == NULL)
        return 2;

    const char *content_type = g_file_info_get_content_type (file_info);
    if (content_type != NULL) {
        desc = g_content_type_get_description (content_type);
        GAppInfo *app_info = g_app_info_get_default_for_type (
                                  content_type,
                                  FALSE);
        if (app_info != NULL) {
            *executable = g_app_info_get_executable (app_info);
        }
    }

    /* you'd have to use g_loadable_icon_load to get the actual icon */
    //GIcon *i = g_file_info_get_icon (file_info);

    *description = desc;
    //GObject *object = (GObject *) g_file_info_get_attribute_object(file_info, G_FILE_ATTRIBUTE_STANDARD_ICON);
    //*icon = g_icon_to_string(object);
    //*icon = g_file_get_path (g_file_icon_get_file (i));
    *mime = content_type;

    return 0;
}

static void get_icon(const char *mime, const char **icon)
{
	*icon = "fa fa-file-o";
	if (mime == NULL)
		return;
	const size_t len = strcspn(mime, "-/");

	if (strncmp(mime, "application", len) == 0) {
	} else if (strncmp(mime, "audio", len) == 0) {
		*icon = "fa fa-file-audio-o";
	} else if (strncmp(mime, "font", len) == 0) {
	} else if (strncmp(mime, "example", len) == 0) {
	} else if (strncmp(mime, "image", len) == 0) {
		*icon = "fa fa-file-image-o";
	} else if (strncmp(mime, "message", len) == 0) {
	} else if (strncmp(mime, "model", len) == 0) {
	} else if (strncmp(mime, "multipart", len) == 0) {
	} else if (strncmp(mime, "text", len) == 0) {
		*icon = "fa fa-file-text-o";
	} else if (strncmp(mime, "video", len) == 0) {
		*icon = "fa fa-file-movie-o";
	} else if (strncmp(mime, "inode", len) == 0) {
		*icon = "fa fa-folder-o";
	}
}

static void list_files(tmpl_cb_t data, tmpl_cb_t cb)
{
	DIR *d;
	struct dirent *dir;
	const char *icon;
	const char *description;
	const char *mime;
	const char *executable;
	const char *dirpath = "/var/www/html/quick";
	char *filepath;
	size_t len;

	d = opendir(dirpath);
	if (d) {
		while ((dir = readdir(d)) != NULL) {
			if (strcmp(dir->d_name, ".") == 0 ||
			    strcmp(dir->d_name, "..") == 0)
			{
				continue;
			}
			len = snprintf(NULL, 0, "%s/%s", dirpath, dir->d_name);
			len++;
			filepath = calloc(sizeof(char),len);
			if (filepath == NULL) {
				exit(1);
			}
			snprintf(filepath, len, "%s/%s", dirpath, dir->d_name);

			cb->add_control_flow(data, SWHILE_TRUE);
			get_file_info(filepath, &description, &mime, &executable);
			get_icon(mime, &icon);
			cb->add_filler_text(data, icon? icon : "");
			cb->add_filler_text(data, dir->d_name);
			cb->add_filler_text(data, mime? mime : "");
			cb->add_filler_text(data, description? description : "");
			cb->add_filler_text(data, executable? executable : "");
		}
		cb->add_control_flow(data, SWHILE_FALSE);
		closedir(d);
	} else {
		fprintf(stderr, "Could not open '%s' directory.", dirpath);
	}
}

static int init(tmpl_ctx_t data, tmpl_cb_t cb)
{
	char *method = getenv("REQUEST_METHOD");
	char *pathinfo = getenv("PATH_INFO");
	char *canonizedpath = NULL;
	char *path = NULL;
	char *file = NULL;
	const char base[] = "/var/www/html/quick";
	size_t len;
	TMPL_ASSERT(method != NULL);
	TMPL_ASSERT(pathinfo != NULL);

	/* concatenate paths */
	len = snprintf(NULL, 0, "%s/%s", base, pathinfo);
	len++;
	path = cb->malloc(data, sizeof(char) * len);
	TMPL_ASSERT(path != NULL);
	snprintf(path, len, "%s/%s", base, pathinfo);

	if (strncmp(base, path, strlen(base)) != 0) {
		fputs("Content-Type: text/plain\r\n", stdout);
		fputs("\r\n", stdout);
		fputs("Invalid path.\n", stdout);
		exit(0);
	}

	/*canonizedpath = realpath(path, NULL);
	TMPL_ASSERT(canonizedpath != NULL);

	fputs("Content-Type: text/plain\r\n", stdout);
	fputs("\r\n", stdout);
	printf("%s\n", canonizedpath);*/

	list_files(data, cb);
	cb->set_output_format(data, TMPL_FMT_HTML);
	cb->send_default_headers(data);
	puts("<!DOCTYPE html>");
	return 0;
}

static void quit() {}

struct pollen_plugin templatizer_plugin_v1 = {
	&init,
	&quit
};


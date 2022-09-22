#include <exception>
#include <tesseract/baseapi.h>
#include <leptonica/allheaders.h>
#include <templatizer.h>
#include <stdlib.h>

tmpl_ctx_t ctx;
struct templatizer_callbacks *cb;

/*void* operator new(std::size_t count)
{
	if (ctx == 0)
		return NULL;
	return cb->malloc(ctx, count);
}*/

void encode(std::string& data) {
    std::string buffer;
    buffer.reserve(data.size());
    for(size_t pos = 0; pos != data.size(); ++pos) {
        switch(data[pos]) {
            case '&':  buffer.append("&amp;");       break;
            case '\"': buffer.append("&quot;");      break;
            case '\'': buffer.append("&apos;");      break;
            case '<':  buffer.append("&lt;");        break;
            case '>':  buffer.append("&gt;");        break;
            default:   buffer.append(&data[pos], 1); break;
        }
    }
    data.swap(buffer);
}

static const char *digitize(char *path)
{
	Pix *image = NULL;
	tesseract::TessBaseAPI *api;

	char *outText = NULL;
	api = new tesseract::TessBaseAPI();
	/* Initialize tesseract-ocr with English,
	   without specifying tessdata path. */
	if (api->Init(NULL, "por"))
		return "Error initializing library.";

	/* Open input image with leptonica library */
	image = pixRead(path);
	api->SetImage(image);
	/* Get OCR result */
	outText = api->GetUTF8Text();

	/* Destroy used object and release memory */
	api->End();
	cb->free(ctx, api);
	pixDestroy(&image);

	return outText;
}

int save_input(char *path)
{
	char *len_string;
	int len, count;
	FILE *file;
	char *buffer;
	char boundary[128];
	char c = 0;
	int line_length = 0;

	len_string = getenv("CONTENT_LENGTH");
	if (len_string == NULL) {
		puts("Could not find CONTENT_LENGTH variable.");
		return 1;
	}
	len = atoi(len_string);
	if (len <= 0) {
		printf("Invalid content length %d.", len);
		return 1;
	}
	buffer = (char *) malloc(len);
	if (buffer == NULL) {
		printf("Failed to allocate %d bytes.\n", len);
		return 1;
	}

	//freopen(NULL, "rb", stdin);

	fgets(boundary, sizeof(boundary), stdin);
	/* account for the two newline characters */
	len -= strlen(boundary) * 2 + 2;

	/*memset(buffer, 0, len);
	fgets(buffer, len, stdin);
	len -= strnlen(buffer, len);
	if (strncmp(buffer, "\r\n", len) != 0 &&
	    strncmp(buffer, "\n", len) != 0)
	{
		puts("Expecting empty line after boundary.");
		return 1;
	}*/

	memset(buffer, 0, len);
	do {
		line_length = 0;
		do {
			//last = c;
			c = fgetc(stdin);
			len--;
			line_length++;
		} while (c != '\n');
	} while (line_length > 2);

	count = fread(buffer, 1, len, stdin);
	if (count < len) {
		puts("Failed to read input.");
		return 1;
	}

	file = fopen(path, "wb");
	if (file == NULL) {
		puts("Failed to open output file.");
		return 1;
	}
	count = fwrite(buffer, 1, len, file);
	if (count < len) {
		puts("Failed to write to output file.");
		return 1;
	}
	fclose(file);

	return 0;
}

static int init(struct context *data, struct templatizer_callbacks *_cb)
{
	const char *text = "";
	char *path;
	int result;

	ctx = data;
	cb = _cb;

	cb->set_output_format(data, TMPL_FMT_HTML);
	cb->send_default_headers(data);
	path = tempnam("/tmp/", "ocr");
	if (path == NULL) {
		puts("Could not create a filename for the temporary file.");
		return 0;
	}
	result = save_input(path);
	if (result) {
		puts("Failed to save input.");
		return 0;
	}
	text = digitize(path);
	if (text == NULL) {
		printf("%s: Failed to digitize document.", path);
		return 0;
	}
	std::string s = std::string(text);
	encode(s);
	cb->add_filler_text(data, s.c_str());
	delete [] text;
	return 0;
}

static void quit() {}

struct templatizer_plugin templatizer_plugin_v1 = {
	&init,
	&quit
};


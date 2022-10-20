AUTOMAKE_OPTIONS=foreign
ACLOCAL_AMFLAGS=-I m4

CFLAGS=$(shell pkg-config --cflags gio-2.0)
CPPFLAGS=-Wall -fPIC
LDFLAGS=--shared -fPIC -Wl,--no-as-needed
DMD=dmd
DFLAGS=-fPIC -preview=dip25 -preview=dip1000 -preview=dip1021 -L="--no-as-needed"
INSTALL_PATH=/var/lib/templatizer/quick
PLUGINS=ocr.so files.so calendar.so money.so nslookup.so transcode.so remote.so
TEMPLATES=ocr.tmpl files.tmpl calendar.tmpl money.tmpl \
	product-page.tmpl nslookup.tmpl transcode.tmpl index.tmpl
TEMPLATES+=header.tmpl footer.tmpl scripts.tmpl css.tmpl
DATA_FILES=app-background.jpg favicon.png
DATA_DIRECTORIES=css/ js/
LOCALIZATION=local/pt_BR/LC_MESSAGES/nslookup.mo

lib_LTLIBRARIES=libocr.la libfiles.la libcalendar.la libnslookup.la libtranscode.la libmoney.la
libocr_la_SOURCES=ocr.cxx
libocr_la_LDFLAGS=-version-info 0:0:0
libocr_la_LIBADD=-ltesseract
libfiles_la_SOURCES=files.c
libfiles_la_LDFLAGS=-version-info 0:0:0 $(shell pkg-config --libs gio-2.0)
libfiles_la_LIBADD=
libcalendar_la_SOURCES=calendar.c
libcalendar_la_LDFLAGS=-version-info 0:0:0
libcalendar_la_LIBADD=-lical
libmoney_la_SOURCES=money.c
libmoney_la_LDFLAGS=-version-info 0:0:0
libmoney_la_LIBADD=-lcsv
libnslookup_la_SOURCES=nslookup.c
libnslookup_la_LDFLAGS=-version-info 0:0:0
libnslookup_la_LIBADD=-ltemplatizer -lGeoIP
libtranscode_la_SOURCES=transcode.c
libtranscode_la_LDFLAGS=-version-info 0:0:0
libtranscode_la_LIBADD=-ltemplatizer -lavformat -lavcodec

plugindir=$(prefix)/lib/templatizer/plugin
libdir=$(plugindir)

all-local: libremote.so

%.o: %.d templatizer.d
	$(DMD) -c $(DFLAGS) -of=$@ $<

libremote.so: remote.o
	$(DMD) -shared $(DFLAGS) -of=$@ $^

apache: apache2/quick.conf
	cp apache2/quick.conf /etc/apache2/conf-available/
	a2enconf quick
	service apache2 reload

po/%.pot: %.c
	mkdir -p po
	xgettext --keyword=gettext --language=C --add-comments --sort-output -o $@ $<
	mkdir -p po/pt_BR/
	echo msginit --no-translator -i $@ -l pt_BR -o po/pt_BR/nslookup.po

po/pt_BR/%.po: po/%.pot
	msgmerge --update $@ $<

local/pt_BR/LC_MESSAGES/%.mo: po/pt_BR/%.po
	mkdir -p local/pt_BR/LC_MESSAGES/
	msgfmt -o $@ $<

test: $(LOCALIZATIO)
	LANG="pt_BR.UTF-8" REQUEST_METHOD="GET" PATH_TRANSLATED="$(shell pwd)/remote.tmpl" /usr/lib/cgi-bin/templatizer

.PHONY: clean install test
.PRECIOUS: po/%.pot po/pt_BR/%.po

AUTOMAKE_OPTIONS=foreign
ACLOCAL_AMFLAGS=-I m4
SUFFIXES=.d

CFLAGS=\
$(shell pkg-config --cflags gio-2.0) \
$(shell pkg-config --cflags apr-1)
CPPFLAGS=-Wall -fPIC
PLUGIN_LDFLAGS=--shared -fPIC -Wl,--no-as-needed
DMD=dmd
DFLAGS=-fPIC -preview=dip25 -preview=dip1000 -preview=dip1021 -L="--no-as-needed"
INSTALL_PATH=/var/lib/templatizer/quick
PLUGINS=ocr.so files.so calendar.so money.so nslookup.so transcode.so remote.so
TEMPLATES=ocr.tmpl files.tmpl calendar.tmpl money.tmpl \
product-page.tmpl nslookup.tmpl transcode.tmpl index.tmpl \
remote.tmpl dav.tmpl microblog.tmpl
TEMPLATES+=header.tmpl footer.tmpl scripts.tmpl css.tmpl
DATA_FILES=app-background.jpg favicon.png
DATA_DIRECTORIES=css/ js/
LOCALIZATION=local/pt_BR/LC_MESSAGES/nslookup.mo

lib_LTLIBRARIES= \
	libocr.la \
	libfiles.la \
	libcalendar.la \
	libnslookup.la \
	libtranscode.la \
	libmoney.la \
	libremote.la \
	libdav.la
libocr_la_SOURCES=ocr.cxx
libocr_la_LDFLAGS=-version-info 0:0:0 $(PLUGIN_LDFLAGS)
libocr_la_LIBADD=-ltesseract
libfiles_la_SOURCES=files.c
libfiles_la_LDFLAGS=-version-info 0:0:0 $(shell pkg-config --libs gio-2.0) $(PLUGIN_LDFLAGS)
libfiles_la_LIBADD=
libcalendar_la_SOURCES=calendar.c
libcalendar_la_LDFLAGS=-version-info 0:0:0 $(PLUGIN_LDFLAGS)
libcalendar_la_LIBADD=-lical
libmoney_la_SOURCES=money.c
libmoney_la_LDFLAGS=-version-info 0:0:0 $(PLUGIN_LDFLAGS)
libmoney_la_LIBADD=-lcsv
libnslookup_la_SOURCES=nslookup.c
libnslookup_la_LDFLAGS=-version-info 0:0:0 $(PLUGIN_LDFLAGS)
libnslookup_la_LIBADD=-ltemplatizer -lGeoIP
libtranscode_la_SOURCES=transcode.c
libtranscode_la_LDFLAGS=-version-info 0:0:0 $(PLUGIN_LDFLAGS)
libtranscode_la_LIBADD=-ltemplatizer -lavformat -lavcodec
libremote_la_SOURCES=remote.d
libremote_la_LDFLAGS=$(PLUGIN_FLAGS)
libremote_la_LIBADD=remote.o -lphobos2
libdav_la_SOURCES=dav.c
libdav_la_LDFLAGS=-version-info 0:0:0 $(PLUGIN_LDFLAGS) -R$(pkgdatadir) -Ldav/lib/ -lDav
libdav_la_LIBADD=dav/lib/libDav.so -llmdb

plugindir=$(pkgdatadir)
libdir=$(plugindir)
plugin_DATA=dav/lib/Dav.so.0.1.0-dev

tmpldir=$(pkgdatadir)
tmpl_DATA=$(TEMPLATES) $(DATA_FILES)

install-data-local:
	cp -r $(DATA_DIRECTORIES) $(pkgdatadir)

$(srcdir)/dav/lib/libDav.so: $(shell ls $(srcdir)/dav/src/*.{ads,adb})
	make -C dav/

%.o: %.d
	$(DMD) -c $(DFLAGS) -of=$@ $<

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
	LANG="pt_BR.UTF-8" REQUEST_METHOD="GET" PATH_TRANSLATED="$(pkgdatadir)/microblog.tmpl" valgrind /usr/lib/cgi-bin/templatizer

clean-local:
	make -C dav clean

.PHONY: clean install $(srcdir)/test
.PRECIOUS: po/%.pot po/pt_BR/%.po

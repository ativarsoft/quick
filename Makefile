CFLAGS=$(shell pkg-config --cflags gio-2.0)
CPPFLAGS=-Wall -fPIC -ltesseract
LDFLAGS=--shared -fPIC -Wl,--no-as-needed
# The following directory stores shared libraries
# and tmpl scripts.
INSTALL_PATH=/var/lib/templatizer/quick
PLUGINS=ocr.so files.so calendar.so money.so
TEMPLATES=ocr.tmpl files.tmpl calendar.tmpl money.tmpl
TEMPLATES+=header.tmpl footer.tmpl scripts.tmpl css.tmpl
DATA_FILES=app-background.jpg favicon.png
DATA_DIRECTORIES=css/ js/

all: $(PLUGINS)

ocr.so: ocr.o
	g++ $(LDFLAGS) -o $@ $< -ltesseract

files.so: files.o
	gcc $(LDFLAGS) -o $@ $< $(shell pkg-config --libs gio-2.0)

calendar.so: calendar.o
	gcc $(LDFLAGS) -o $@ $< -lical

money.so: money.o
	gcc $(LDFLAGS) -o $@ $< -lcsv

install: $(PLUGINS) $(TEMPLATES) $(DATA_FILES) $(DATA_DIRECTORIES)
	rm -fr $(INSTALL_PATH)
	mkdir -p $(INSTALL_PATH)
	cp $(TEMPLATES) $(INSTALL_PATH)
	cp $(PLUGINS) $(INSTALL_PATH)
	cp $(DATA_FILES) $(INSTALL_PATH)
	cp -r $(DATA_DIRECTORIES) $(INSTALL_PATH)
	chown -R www-data:www-data $(INSTALL_PATH)
	chmod a=rx $(INSTALL_PATH)
	chmod 544 $(INSTALL_PATH)/*
	cp apache2/quick.conf /etc/apache2/conf-available/
	a2enconf quick
	service apache2 reload

clean:
	rm -f $(PLUGINS) *.o access.log

.PHONY: clean

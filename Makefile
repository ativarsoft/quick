CFLAGS=$(shell pkg-config --cflags gio-2.0)
CPPFLAGS=-Wall -fPIC -ltesseract
LDFLAGS=--shared -fPIC -Wl,--no-as-needed
INSTALL_PATH=/var/www/wordpress/quick
PLUGINS=ocr.so files.so calendar.so money.so

all: $(PLUGINS)

ocr.so: ocr.o
	g++ $(LDFLAGS) -o $@ $< -ltesseract

files.so: files.o
	gcc $(LDFLAGS) -o $@ $< $(shell pkg-config --libs gio-2.0)

calendar.so: calendar.o
	gcc $(LDFLAGS) -o $@ $< -lical

money.so: money.o
	gcc $(LDFLAGS) -o $@ $< -lcsv

install: $(PLUGINS)
	rm -fr $(INSTALL_PATH)
	mkdir -p $(INSTALL_PATH)
	cp header.tmpl footer.tmpl scripts.tmpl css.tmpl $(INSTALL_PATH)
	cp ocr.tmpl ocr.so $(INSTALL_PATH)
	cp files.tmpl files.so $(INSTALL_PATH)
	cp calendar.tmpl calendar.so $(INSTALL_PATH)
	cp product-page.tmpl  $(INSTALL_PATH)
	cp money.tmpl money.so $(INSTALL_PATH)
	cp app-background.jpg favicon.png $(INSTALL_PATH)
	cp -r css/ js/ $(INSTALL_PATH)
	chown -R www-data:www-data $(INSTALL_PATH)
	chmod a=rx $(INSTALL_PATH)
	chmod 544 $(INSTALL_PATH)/*

clean:
	rm -f $(PLUGINS) *.o access.log

.PHONY: clean install

CPPFLAGS=-Wall -fPIC -ltesseract
LDFLAGS=--shared -fPIC -Wl,--no-as-needed -ltesseract
INSTALL_PATH=/var/www/html/quick

all: ocr.so

ocr.so: ocr.o
	g++ $(LDFLAGS) -o $@ $<

install: ocr.so
	mkdir -p $(INSTALL_PATH)
	cp header.tmpl footer.tmpl scripts.tmpl $(INSTALL_PATH)
	cp ocr.tmpl ocr.so $(INSTALL_PATH)
	cp files.tmpl $(INSTALL_PATH)
	cp calendar.tmpl $(INSTALL_PATH)
	cp product-page.tmpl app-background.jpg favicon.png $(INSTALL_PATH)
	chown -R www-data:www-data $(INSTALL_PATH)
	chmod a=rx $(INSTALL_PATH)
	chmod 544 $(INSTALL_PATH)/*

clean:
	rm -f ocr.so ocr.o

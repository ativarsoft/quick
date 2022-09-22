CPPFLAGS=-Wall -fPIC -ltesseract
LDFLAGS=--shared -fPIC -Wl,--no-as-needed -ltesseract
INSTALL_PATH=/var/www/html/ocr

all: ocr.so

ocr.so: ocr.o
	g++ $(LDFLAGS) -o $@ $<

install:
	mkdir -p $(INSTALL_PATH)
	cp index.html ocr.so ocr.tmpl $(INSTALL_PATH)
	chown -R www-data:www-data $(INSTALL_PATH)
	chmod a=rx $(INSTALL_PATH)
	chmod 544 $(INSTALL_PATH)/*

clean:
	rm -f ocr.so ocr.o

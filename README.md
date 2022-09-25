# Ativarsoft Quick

Ativarsoft Quick is a cloud service.
It is in early development stages.

  * digitize images and transform them into text using OCR;
  * organize your callendar;
  * backup and manage files on the cloud.

## Buiding

Build everything with the following commands:

  make
  sudo make install

Module can be built individually.

  make module.so

Available modules:

  * ocr.so
  * calendar.so
  * files.so

### Dependencies

All modules:

  * templatizer
  * libgettextpo-dev

Calendar (calendar.so):

  * libical-dev

Files (files.so):

  * libglib2.0-dev

OCR (ocr.so):

  * libtesseract-dev

import gohai.simplereceiptprinter.*;
import processing.serial.*;
SimpleReceiptPrinter printer;

import gohai.glvideo.*;
GLCapture video;
PImage img;
PShader shader;


void setup() {
  size(384, 384, P2D);
  
  // PRINTER SETUP
  String[] ports = SimpleReceiptPrinter.list();
  println("Available serial ports:");
  printArray(ports);
  // you might need to use a different port
  String port = ports[0];
  println("Attempting to use " + port);
  printer = new SimpleReceiptPrinter(this, port, 2.09, 19200);

  // CAMERA SETUP
  String[] devices = GLCapture.list();
  println("Devices:");
  printArray(devices);
  if (0 < devices.length) {
    String[] configs = GLCapture.configs(devices[0]);
    println("Configs:");
    printArray(configs);
  }
  
  

  // this will use the first recognized camera by default
  
  // CAMERA CONFIGS
  //video = new GLCapture(this, devices[0], printer.width, printer.width, 12);
  video = new GLCapture(this, devices[0], 384, 384, 12);
  
  // you could be more specific also, e.g.
  //video = new GLCapture(this, devices[0]);
  //video = new GLCapture(this, devices[0], 640, 480, 25);
  //video = new GLCapture(this, devices[0], configs[0]);

  video.start();

}

void draw() {
  String[] prices = loadStrings("prices.txt");
  String[] funQuote = loadStrings("quotes.txt");
  background(0);
  if (video.available()) {
    video.read();
  }
  image(video, 0, 0, width, height);
  
  // FILTERS (need to check if these are preview only or not)
  //filter(GRAY);
  //filter(POSTERIZE, 10);
  
  if (mousePressed) {
    saveFrame("capture.jpg");
    img = loadImage("capture.jpg");
    img.resize(printer.width, 0);
    dither(img);
    image(img, 0, 0);
    printer.printBitmap(get());
    
    // Price printer
    int priceIndex = int(random(prices.length));
    String price = " Total: " + prices[priceIndex];
    for(int i = 0; i < 29 - (price.length()); i++){
      printer.print(" ");
    }
    printer.println(price);
    printer.println("Hell is empty and all the devils are here");

    printer.feed(3);
    delay(3000);
    
  }
}

/*
 * This implements Bill Atkinson's dithering algorithm
 */
void dither(PImage img) {
  img.loadPixels();

  for (int y=0; y < img.height; y++) {
    for (int x=0; x < img.width; x++) {
      // set current pixel and error
      float bright = brightness(img.pixels[y*img.width+x]);
      float err;
      if (bright <= 127) {
        img.pixels[y*img.width+x] = 0x000000;
        err = bright;
      } else {
        img.pixels[y*img.width+x] = 0xffffff;
        err = bright-255;
      }
      // distribute error
      int offsets[][] = new int[][]{{1, 0}, {2, 0}, {-1, 1}, {0, 1}, {1, 1}, {0, 2}};
      for (int i=0; i < offsets.length; i++) {
        int x2 = x + offsets[i][0];
        int y2 = y + offsets[i][1];
        if (x2 < img.width && y2 < img.height) {
          float bright2 = brightness(img.pixels[y2*img.width+x2]);
          bright2 += err * 0.125;
          bright2 = constrain(bright2, 0.0, 255.0);
          img.pixels[y2*img.width+x2] = color(bright2);
        }
      }
    }
  }

  img.updatePixels();
}

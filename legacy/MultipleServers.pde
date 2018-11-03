// Variables
final boolean showUser = false; /* Show kinect user mask */
final boolean isKinect = true;


import codeanticode.syphon.*;
import java.awt.event.KeyEvent.*;

int nServers = 4;
PGraphics[] canvas;
SyphonServer[] servers;
SpringSakura springSakura;
SummerBubble summerBubble;
AutumnFirefly autumnFirefly;
WinterSnow winterSnow;
MyKinect mk;

//void settings() {
//  size(1000, 1000);
//}

void setup() {
  size(2560, 1440, P3D);

  canvas = new PGraphics[nServers];
  for (int i = 0; i < nServers; i++) {
    canvas[i] = createGraphics(1280 , 720, P3D);
  }

  // Create syhpon servers to send frames out.
  servers = new SyphonServer[nServers];
  for (int i = 0; i < nServers; i++) { 
    servers[i] = new SyphonServer(this, "Processing Syphon."+i);
  }

  if (isKinect) {
    mk = new MyKinect(this);
  } else {
    mk = null;
  }

  springSakura = new SpringSakura();
  summerBubble = new SummerBubble();
  autumnFirefly = new AutumnFirefly();
  winterSnow = new WinterSnow();
}

void draw() {
  if (isKinect) {
    mk.update();
  }
  for (int i = 0; i < nServers; i++) {
    canvas[i].beginDraw();
    canvas[i].background(0);
    if (showUser && isKinect) {
      mk.drawUser(canvas[i]);
    }

    if (i == 0) {
      // 1st server (Spring)
      springSakura.update(mk, canvas[i]);
    } else if (i == 1) {
      // 2nd server (Summer)
      summerBubble.update(mk, canvas[i]);
    } else if (i == 2) {
      // 3rd server (Fall)
      autumnFirefly.update(mk, canvas[i]);
    } else if (i == 3) {
      // 4th server (Winter)
      //summerBubble.update(mk, canvas[i]);
      winterSnow.update(mk, canvas[i]);
    }

    canvas[i].endDraw();
    image(canvas[i], 1280 * (i % 2), 720 * (i / 2));
    servers[i].sendImage(canvas[i]);
  }
}

void onNewUser(SimpleOpenNI kinect, int userID) {
  println("Start skeleton tracking");
  kinect.startTrackingSkeleton(userID);
}

void onLostUser(SimpleOpenNI curContext, int userId) {
  println("onLostUser - userId: " + userId);
}

void keyPressed() {
  if (key == 'r') {
    winterSnow = new WinterSnow();
  }
}

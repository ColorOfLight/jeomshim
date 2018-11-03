// main

// Variables
final boolean showUser = false; /* Show kinect user mask */
final boolean isKinect = false;
final boolean showText = true;
public final float GLOWING_SIZE = 20;
public final float SENSOR_PADDING = 30;

MyKinect mk;
int currentState;
int counterMillis = 0;

CenterInteraction ir1, ir4;
Ripples ir2;
Firework ir3;
GlowingHand mouseGH, leftGH, rightGH;

void setup() {
  size(1280, 720);
  noSmooth();

  if (isKinect) {
    mk = new MyKinect(this);
    leftGH = new GlowingHand(GLOWING_SIZE);
    rightGH = new GlowingHand(GLOWING_SIZE);
  } else {
    mk = null;
    mouseGH = new GlowingHand(GLOWING_SIZE);
  }

  currentState = 0;
  ir1 = new CenterInteraction(true);
  ir2 = new Ripples();
  ir3 = new Firework();
  ir4 = new CenterInteraction(false);
}

void draw() {
  background(0);

  if (isKinect) {
    if (mk.ableGetLeft) leftGH.display(mk.leftHand.x, mk.leftHand.y);
    if (mk.ableGetRight) rightGH.display(mk.leftHand.x, mk.rightHand.y);
  } else {
    mouseGH.display(mouseX, mouseY);
  }

  if (currentState == 0) {
    ir1.update(mk);
    if (ir1.didEnd()) {
      currentState++;
    }
  } else if (currentState == 1) {
    ir2.update(mk);
    if (counterMillis > 0) {
      if (millis() - counterMillis > 1 * 1000 ) {
        currentState++;
        counterMillis = 0;
      }
    }
    else if (ir2.didEnd()) {
     counterMillis = millis();
    }
  } else if (currentState == 2) {
    ir3.update(mk);
    if (counterMillis > 0) {
      if (millis() - counterMillis > 3 * 1000 ) {
        currentState++;
        counterMillis = millis();
      }
    }
    else if (ir3.didEnd()) {
      counterMillis = millis();
    }
  } else if (currentState == 3) {
    ir4.update(mk);
    if (counterMillis > 0) {
      if (millis() - counterMillis > 5 * 1000 ) {
        currentState++;
        counterMillis = millis();
      }
    }
    else if (ir4.didEnd()) {
      counterMillis = millis();
    }
  }

  // Show Log
  if (showText) {
    textSize(24);
    text("state: " + currentState, 10, 30); 
    fill(0, 102, 153);
  }
}

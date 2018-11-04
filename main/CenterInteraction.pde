// Reference
// https://www.openprocessing.org/sketch/602896

import java.util.*;

public final float[] INTRO_ELLIPSIS = {960, 540, 10, 10};

public class CenterInteraction {
  private boolean isFinished;
  private boolean isIntro;
  private List<Star> stars;

  CenterInteraction(boolean isIntro) {
    this.isFinished = false;
    this.isIntro = isIntro;
    if (!isIntro) {
      this.stars = new ArrayList<Star>();
      for (int a = 0; a < random(40, 50); a++) {
        Star s = new Star(width / 2, height / 2, 50 + a * random(10, 15));
        stars.add(s);
      }
    }
  }

  void update(MyKinect mk) {
    fill(255);
    noStroke();
    ellipse(INTRO_ELLIPSIS[0], INTRO_ELLIPSIS[1], INTRO_ELLIPSIS[2], INTRO_ELLIPSIS[3]);

    if (!isIntro) {
      for (int i = 0; i < stars.size(); i++) {
        stars.get(i).display();
      }
    }

    if (mk != null) {
      move(mk.ableGetLeft, mk.leftHand.x, mk.leftHand.y);
    } else {
      move(mousePressed, mouseX, mouseY);
    }
  }

  void move(boolean cond, float x, float y) {
    if (cond) {
      if (abs(x - INTRO_ELLIPSIS[0]) <= SENSOR_PADDING && abs(y - INTRO_ELLIPSIS[1]) <= SENSOR_PADDING) {
        if (isIntro) {
          this.isFinished = true;
        } else {
          for (int i = 0; i < stars.size(); i++) {
            stars.get(i).move();
          }
          this.isFinished = true;
        }
      }
    }
  }

  boolean didEnd() {
    return this.isFinished;
  }
}

class Star {
  PVector location;
  float degree;
  float startdegree;
  float radius;
  float volecity;
  int linecolor;

  Star(float x, float y, float z) {
    location = new PVector(x, y);
    degree = 0.1;
    startdegree = random(0, 360);
    volecity = random(0.1, 0.5);
    linecolor = int(random(150, 255));
    radius = z;
  }

  void display() {
    stroke(linecolor, linecolor, 200);
    noFill();
    arc(location.x, location.y, radius, radius, radians(startdegree), radians(degree + startdegree));
  }

  void move() {
    degree += volecity;
  }

  void reset() {
    degree = 0.5;
  }
}

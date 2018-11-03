import java.util.*;

// Color
final int fireflyRed = 255;
final int fireflyGreen = 200;
final int fireflyBlue = 59;

// Number of flies
final int fireflyNum = 3;

public class AutumnFirefly {
  ArrayList<Firefly> flies;
  List<Firefly> removeFlies;
  
  AutumnFirefly() {
    flies = new ArrayList();
    removeFlies = new ArrayList();
  }
  
  void update(MyKinect mk, PGraphics p) {
    if (mk == null) {
      for (int i = 0; i < fireflyNum; i++) {
        if (mousePressed) {
          flies.add(new Firefly(mouseX, mouseY));
        }
      }
    } else if (mk.ableGetCenter) {
      for (int i = 0; i < fireflyNum; i++) {
        flies.add(new Firefly(mk.center.x, mk.center.y));
      }
    }
  
    for (Firefly f: flies) {
      f.display(p);
  
      if (f.life < 0) {
        removeFlies.add(f);
      }
    }
    
    for (Firefly f: removeFlies) {
      flies.remove(f);
    }
    removeFlies = new ArrayList();
  }
}

// Firefly class
class Firefly {
  PVector pos;
  float life;
  float lifeRate;
  float angle;
  float maxScale;
  float rotateRate;
  float maxOffset;
  float hue;

  Firefly(float x, float y) {
    pos = new PVector(x, y);
    life = 1.0;
    lifeRate = random(0.005, 0.02);
    angle = map(cos(radians(frameCount * 5)), -1, 1, -180, 180);
    maxScale = max(0.25, abs(sin(radians(frameCount * 5)) * 1.5));
    rotateRate = random(-200, 200);
    maxOffset = random(50, 300);
    hue = 0;
  }

  void display(PGraphics p) {
    float offset = map(this.life, 1, 0, 0, this.maxOffset); // Pushes out along x axis.

    // Scales from particle's origin pivot.
    float s;
    s = map(this.life, 1, 0, this.maxScale, 0);

    float t = map(this.life, 1, 0, 0, 1); // Represents the time of the particle's life.

    float opacity = map(this.life, 1, 0, 255, 0);

    p.noStroke(); // Show stroke slightly darker.
    p.fill(color(fireflyRed, fireflyGreen, fireflyBlue, opacity * .8));

    p.pushMatrix();

    // Creates a spiral motion.
    p.translate(this.pos.x, this.pos.y);
    p.rotate(radians(this.angle + t * this.rotateRate));
    p.scale(s);

    p.ellipse(offset, 0, 20, 20);

    p.popMatrix();

    this.life -= this.lifeRate;
  }
}

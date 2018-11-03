import java.util.*;

// Number of petals
final int sakuraNum = 100;

// Color and texture to be revised (꽃잎의 색이나 텍스쳐는 수정할 때 추가작업이 필요합니다)

final float maxXVelo = 3;
final float sakuraPadding = 300;
final float sakuraYpadding = 150;
final float force = .25;
final int sakuraColors[] = {color(244, 191, 252, 150), color(255, 219, 248, 150), color(246, 204, 252, 150)};
//public PImage img;

public class SpringSakura {
  List<Sakura> fubuki = new ArrayList();
  
  SpringSakura() {
    fubuki = new ArrayList();
    
    for (int i = 0; i < sakuraNum; i++) {
      fubuki.add(new Sakura());
    }
    
    noStroke();
    //img = loadImage("flower_texture.png");
  }
  
  void update(MyKinect mk, PGraphics p) {
    for (Sakura s: fubuki) {
      s.draw(p);
      if (mk == null) {
        s.move(mousePressed, mouseX, mouseY);
      } else {
        s.move(mk.ableGetLeft, mk.leftHand.x, mk.leftHand.y);
      }
    }
  }
}

class Sakura {
  float xDef, xAmp;
  float xSpeed;
  float xTheta;
  float ox, oy;
  float rotateT;
  float size;
  float ySpeed;
  float sizeYScale;
  float sizeYT, sizeYSpeed;
  int c;
  float xVelo;
  
  Sakura() {
     this.xDef = random(width);
  
      this.xAmp = random(200,400);
      this.xSpeed = random(1,.25);
      this.xTheta = random(360);
      
      this.ox = this.xDef + this.xAmp * sin(radians(this.xTheta));
      this.oy = random(height);
      this.rotateT = random(360);
      this.size = random(30, 5);
    
      this.ySpeed = this.size / 20;
      this.sizeYScale = 1;
      this.sizeYT = random(360);
      this.sizeYSpeed = this.size / 30;
      this.c = floor(random(0, sakuraColors.length));
      this.xVelo = 0;
  }
  
  public void draw(PGraphics p) {
     int n = 4;
     float A, md, r, x, y, R;
    
    p.fill(sakuraColors[this.c]);

    p.pushMatrix();
    p.translate(this.ox, this.oy);
    p.rotate(radians(this.rotateT));
    p.beginShape();
    p.noStroke();

    for (int t = 0; t < 360 / 4; t++) {
      A = n / PI * radians(t);

      md = floor(A) % 2;

      r = pow(-1, md) * (A - floor(A)) + md;

      R = r + 1 * calcH(r);

      x = this.size * R * cos(radians(t));
      y = this.size * this.sizeYScale * R * sin(radians(t));

      p.vertex(x, y, 1000 + 20*x, 1000 + 20*y);
    }
    p.endShape(CLOSE);
    p.popMatrix();
  }
  
  public void move(boolean cond, float x, float y) {
    if (cond) {
      if (this.oy < y + sakuraYpadding && this.oy > y - sakuraYpadding) {
        if (this.ox < x - sakuraPadding) {
          this.xVelo = min(maxXVelo, xVelo + force);
        } else if (this.ox > x + sakuraPadding) {
          this.xVelo = min(-maxXVelo, xVelo - force);
        }
      }
    }
    
    this.xDef += this.xVelo * abs(x - this.ox) / 100;
    this.xDef += this.xVelo;
    this.xVelo *= 0.9;
    
    this.ox = this.xDef + this.xAmp * sin(radians(this.xTheta));
    this.xTheta += this.xSpeed;
    
    this.oy += this.ySpeed;
    this.sizeYT += this.sizeYSpeed;
    this.sizeYScale = abs(sin(radians(this.sizeYT)));

    if (this.oy > height + this.size) {
      this.oy = -this.size;
      this.xVelo = 0;
      this.xDef = random(width);
      this.ox = this.xDef + this.xAmp * sin(radians(this.xTheta));
    }
  }
}

float calcH(float x) {
  if (x < 0.85) {
    return 0;
  } else {
    return 0.85 - x;
  }
}

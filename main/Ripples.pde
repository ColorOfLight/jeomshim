// Reference
// https://www.openprocessing.org/sketch/616760

int block_size = 50;
int block_core = 1;
int block_move_distance = 10;
int block_move_range = 70;
float block_scale = .02;
float ripple_speed = .24;

boolean show_ripples = false;
boolean show_info = false;

float mouse_speed;
int fps, avgFps = 0;
int prevFrame = 0;
int prevTime = 0;
int fpsInterval = 1000;

List<Ripple> ripples = new ArrayList<Ripple>();
List<Ripple> removeRipples = new ArrayList<Ripple>();

public class Ripples {
  boolean isFinished;
  float left_padding, top_padding;
  PImage b;
  List<Block> blocks;
  float tmp_x1, tmp_y1;

  Ripples() {
    this.isFinished = false;

    left_padding = round(width % block_size) / 2;
    top_padding = round(height % block_size) / 2;

    tmp_x1 = -1;
    tmp_y1 = -1;


    b = loadImage("#ripple.jpg");
    fps = 30;

    blocks = new ArrayList<Block>();
    for (int x=0;x<floor(width / block_size);x++) {
      for (int y=0;y<floor(height / block_size);y++) {
        blocks.add(new Block(
          left_padding + block_size * (x + 0.5),
          top_padding + block_size * (y + 0.5),
          y * floor(width / block_size) + x
        ));
      }
    }
  }

  void update(MyKinect mk) {
    image(b,0,0,width,height);

    noStroke();
    fill(233, 230);
    rectMode(CENTER);

    if (random(1.0) < pow(fps / 60, 3) / 16) {
        ripples.add(new Ripple(random(width), random(height), 0.1));
    }

    if (millis() - prevTime > fpsInterval) {
        avgFps = (frameCount - prevFrame) / fpsInterval * 1000;
        prevFrame = frameCount;
        prevTime = millis();
    }

    for (Ripple ripple: ripples) {
      ripple.updateRadius();
      ripple.checkKill();
    }
    for (Ripple r: removeRipples) {
      ripples.remove(r);
    }

    for (Block block: blocks) {
      block.calcDiff(ripples);
      block.render();
    }

    if (mk != null) {
      if (mk.ableGetLeft) {
        if (tmp_x1 < 0 || tmp_y1 < 0) {
          tmp_x1 = mk.leftHand.x;
          tmp_y1 = mk.leftHand.y;
        } else {
          mouse_speed = dist(mk.leftHand.x, mk.leftHand.y, tmp_x1, tmp_y1);
          tmp_x1 = mk.leftHand.x;
          tmp_y1 = mk.leftHand.y;
          move(mk.ableGetLeft, mk.leftHand.x, mk.leftHand.y);
        }
      }
    } else {
      mouse_speed = dist(mouseX, mouseY, pmouseX, pmouseY);
      move(mousePressed, mouseX, mouseY);
    }
  }

  void move(boolean cond, float x, float y) {
    if (cond) {
      ripples.add(new Ripple(x, y, 0.15 * mouse_speed / 40));
      this.isFinished = true;
    }
  }

  boolean didEnd() {
    return this.isFinished;
  }
}

class Block {
  PVector pos, diff;
  int id;
  float amp;
  float angle;

    Block(float x, float y, int id) {
        this.pos = new PVector(x, y);
        this.id = id;
    }

    void render() {
        fill(0,92,254, cubicInOut(this.amp, 60, 240, 15));
        rect(this.pos.x + this.diff.x, this.pos.y + this.diff.y, (block_core + this.amp * block_scale) * 5, block_core + this.amp * block_scale * 0.5);
        rect(this.pos.x + this.diff.x, this.pos.y + this.diff.y, block_core + this.amp * block_scale * 0.5, (block_core + this.amp * block_scale) * 5);
    }

    /**
     * @param {Ripple[]} ripples
     */
    void calcDiff(List<Ripple> ripples) {
        this.diff = new PVector(0, 0);
        this.amp = 0;

        for (Ripple ripple: ripples) {
          int bid;
          if (ripple.indexes.contains(this.id)) {
            bid = ripple.indexes.indexOf(this.id);
          } else {
            bid = ripple.indexes.size();
            ripple.indexes.add(this.id);
            ripple.dists.add(dist(this.pos.x, this.pos.y, ripple.pos.x, ripple.pos.y));
            PVector tmp = new PVector(this.pos.x, this.pos.y);
            ripple.angles.add(tmp.sub(ripple.pos).heading());
          }
          float distance = ripple.dists.get(bid) - ripple.currRadius;
          if (distance < 0 && distance > -block_move_range * 2) {
              float angle = ripple.angles.get(bid);
              float localAmp = cubicInOut(-abs(block_move_range + distance) + block_move_range, 0, block_move_distance, block_move_range) * ripple.scale;
              this.amp += localAmp;
              PVector movement = PVector.fromAngle(angle).mult(localAmp);
              this.diff.add(movement);
          }
        }
    }

}

class Ripple {
    PVector pos;
    int initTime;
    float currRadius, endRadius, scale;
    List<Float> dists, angles;
    List<Integer> indexes;

    Ripple(float x, float y, float scale) {
        this.pos = new PVector(x, y);
        this.initTime = millis();
        this.currRadius = 10;
        this.endRadius = max(dist(this.pos.x, this.pos.y, 0, 0), dist(this.pos.x, this.pos.y, 0, height), dist(this.pos.x, this.pos.y, width, 0));
        this.endRadius = max(this.endRadius, dist(this.pos.x, this.pos.y, height, width)) + block_move_range;
        this.scale = scale;

        this.dists = new ArrayList<Float>();
        this.angles = new ArrayList<Float>();
        this.indexes = new ArrayList<Integer>();
    }

    void checkKill() {
        if (this.currRadius > this.endRadius) {
            removeRipples.add(this);
        }
    }

    void updateRadius() {
        this.currRadius = (millis() - this.initTime) * ripple_speed;
        //this.currRadius = 200;
    }
}

float cubicInOut(float t, float b, float c, float d) {
    if (t <= 0) return b;
    else if (t >= d) return b + c;
    else {
        t /= d / 2;
        if (t < 1) return c / 2 * t * t * t + b;
        t -= 2;
        return c / 2 * (t * t * t + 2) + b;
    }
}

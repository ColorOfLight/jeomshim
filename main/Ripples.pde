// // Reference
// // https://www.openprocessing.org/sketch/616760

// int block_size = 25;
// int block_core = 1;
// int block_move_distance = 10;
// int block_move_range = 70;
// float block_scale = .02;
// float ripple_speed = .24;

// boolean show_ripples = false;
// boolean show_info = false;

// float mouse_speed;
// int fps, avgFps = 0;
// int prevFrame = 0;
// int prevTime = 0;
// int fpsInterval = 1000;

// public class Ripples {
//   boolean isFinished;
//   float left_padding, top_padding;
//   PImage b;

//   Ripples() {
//     this.isFinished = false;

//     left_padding = round(width % block_size) / 2;
//     top_padding = round(height % block_size) / 2;

//     b = loadImage("ocean2.jpg");
//     fps = frameRate();
//   }

//   void update(MyKinect mk) {
//     image(b,0,0,width,height);

//     noStroke();
//     fill(233, 230);
//     rectMode(CENTER);

//     if (random() < pow(fps / 60, 3) / 16) {
//         ripples.push(new Ripple(random(width), random(height), 0.1));
//     }

//     if (millis() - prevTime > fpsInterval) {
//         avgFps = (frameCount - prevFrame) / fpsInterval * 1000;
//         prevFrame = frameCount;
//         prevTime = millis();
//     }

//     if (mk != null) {
//       // move();
//     } else {
//       move(mousePressed, mouseX, mouseY);
//     }
//   }

//   void move(boolean cond, float x, float y) {
//     if (cond) {
      
//     }
//   }

//   boolean didEnd() {
//     return this.isFinished;
//   }
// }

// class Block {
//   PVector pos, diff;
//   int id;
//   float angle;

//     Block(float x, float y, int id) {
//         this.pos = createVector(x, y);
//         this.id = id;
//     }

//     void render() {
//         fill(0,92,254, cubicInOut(this.amp, 60, 240, 15));
//         rect(this.pos.x + this.diff.x, this.pos.y + this.diff.y, (block_core + this.amp * block_scale) * 5, block_core + this.amp * block_scale * 0.5);
//         rect(this.pos.x + this.diff.x, this.pos.y + this.diff.y, block_core + this.amp * block_scale * 0.5, (block_core + this.amp * block_scale) * 5);
//     }

//     /**
//      * @param {Ripple[]} ripples
//      */
//     void calcDiff(ripples) {
//         this.diff = createVector(0, 0);
//         this.amp = 0;

//         ripples.forEach((ripple, i) => {
//             if (!ripple.dists[this.id]) {
//                 ripple.dists[this.id] = dist(this.pos.x, this.pos.y, ripple.pos.x, ripple.pos.y);
//             };
//             let distance = ripple.dists[this.id] - ripple.currRadius;
//             if (distance < 0 && distance > -block_move_range * 2) {
//                 if (!ripple.angles[this.id]) {
//                     ripple.angles[this.id] = p5.Vector.sub(this.pos, ripple.pos).heading();
//                 };
//                 const angle = ripple.angles[this.id];
//                 const localAmp = cubicInOut(-abs(block_move_range + distance) + block_move_range, 0, block_move_distance, block_move_range) * ripple.scale;
//                 this.amp += localAmp;
//                 const movement = p5.Vector.fromAngle(angle).mult(localAmp);
//                 this.diff.add(movement);
//             }
//         });
//     }

// }

// class Ripple {
//     PVector pos;
//     int initTime;
//     float currRadius, endRadius;
//     List<Float> dists, angles;

//     Ripple(float x, float y, float scale) {
//         this.pos = createVector(x, y);
//         this.initTime = millis();
//         this.currRadius = 0;
//         this.endRadius = max(dist(this.pos.x, this.pos.y, 0, 0), dist(this.pos.x, this.pos.y, 0, height), dist(this.pos.x, this.pos.y, width, 0), dist(this.pos.x, this.pos.y, height, width)) + block_move_range;
//         this.scale = scale;

//         this.dists = [];
//         this.angles = [];
//     }

//     void checkKill() {
//         if (this.currRadius > this.endRadius) {
//             ripples.splice(ripples.indexOf(this), 1);
//         }
//     }

//     void updateRadius() {
//         this.currRadius = (millis() - this.initTime) * ripple_speed;
//         //this.currRadius = 200;
//     }

//     void draw() {
//         stroke(255, cubicInOut(this.scale, 30, 120, 1));
//         noFill();
//         ellipse(this.pos.x, this.pos.y, this.currRadius * 2, this.currRadius * 2);
//     }
// }

// float cubicInOut(float t, float b, float c, float d) {
//     if (t <= 0) return b;
//     else if (t >= d) return b + c;
//     else {
//         t /= d / 2;
//         if (t < 1) return c / 2 * t * t * t + b;
//         t -= 2;
//         return c / 2 * (t * t * t + 2) + b;
//     }
// }
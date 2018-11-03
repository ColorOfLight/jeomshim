class GlowingHand {
  float radius; //mass
  float G;  //gravity constant
  PVector location;

  PImage glow;

  GlowingHand (float _radius) {
    location = new PVector(0, 0);
    radius = _radius;

    glow = loadImage("glow.png");
  }

  void display (float x, float y) {
    location = new PVector(x, y);

    pushMatrix();
    translate(location.x, location.y);
    scale(radius*0.02, radius*0.02);
    tint(80,80,80);
    image(glow, -glow.width/2, -glow.height/2);
    popMatrix();

    fill(120, 120, 120);
    ellipse(location.x, location.y, radius*2, radius*2);
  }
}
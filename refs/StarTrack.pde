//imitating star track in the sky

ArrayList < Star > stars = new ArrayList < Star > ();

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
    if (mousePressed == true) {
      degree += volecity;
    }
  }

  void reset() {
    degree = 0.5;
  }
}

void setup() {
  size(800, 800);
  for (int a = 0; a < random(40, 50); a++) {
    Star s = new Star(400, 400, 50 + a * random(10, 15));
    stars.add(s);
  }
}

void draw() {
  background(0, 13, 71);
  for (int i = 0; i < stars.size(); i++) {
    stars.get(i).display();
  }
  for (int i = 0; i < stars.size(); i++) {
    stars.get(i).move();
  }
}


void mouseReleased() {
  for (int i = 0; i < stars.size(); i++) {
    stars.get(i).reset();
  }
}
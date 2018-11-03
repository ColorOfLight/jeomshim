int ballAmount = 300;
Ball [] balls = new Ball[ballAmount];
Attractor attractor;
int bgHue, bgSatur, bgBright;

void setup () {
  size(640, 640);
  colorMode(HSB, 360, 100, 100, 100);
  background(0);
  
  bgHue = 210;
  bgSatur = 50;
  bgBright = 0;

  for (int i = 0; i < ballAmount; i++) {
    balls [i] = new Ball(random(5, 10), i, balls);
  }
  attractor = new Attractor(30);
}

void draw () {
  //background
  noStroke();
  fill(bgHue, bgSatur, bgBright, 35);
  rect(0, 0, width, height);
  
  attractor.display();

  for (int i = 0; i < balls.length; i++) {
    //force is the attraction strength in the attractor class
    //the strength is different on each ball
    PVector force = attractor.attract(balls[i]);
    
    balls[i].ballCollision();
    balls[i].flock();
    
    //repelled when close and attracted when far
    float dist = PVector.dist(balls[i].location, attractor.location);
    if (dist < attractor.radius*5) {
      force.mult(-4);
      balls[i].applyForce(force);
    } else if (dist > attractor.radius*5 & dist < attractor.radius*6) {
      force.mult(0);
      balls[i].applyForce(force);
    }
    
    balls[i].movement();
    balls[i].boundaryCollision();
    balls[i].display();
  }
}
class Attractor {
  float radius; //mass
  float G;  //gravity constant
  PVector location;

  PImage glow;

  Attractor (float _radius) {
    location = new PVector(0, 0);
    radius = _radius;
    G = 1;

    glow = loadImage("glow.png");
  }

  PVector attract (Ball b) {
    PVector force = PVector.sub(location, b.location); //direction
    float d = force.mag();  //distance
    d = constrain(d, 5.0, 25.0);  //prevents extremely far and close distance values
    force.normalize();  //becomes 1 (this is for direction)
    float strength = (G * radius * b.radius) / (d * d); //attraction strength
    force.mult(strength);      
    return force;
  }

  void display () {
    location = new PVector(mouseX, mouseY);

    pushMatrix();
    translate(location.x, location.y);
    scale(radius*0.02, radius*0.02);
    tint(80,80,80);
    image(glow, -glow.width/2, -glow.height/2);
    popMatrix();

    fill(80, 50, 80);
    ellipse(location.x, location.y, radius*2, radius*2);
  }
}

class Ball {
  float radius; //mass
  PVector location, velocity, acceleration;

  int trailNum = 50;
  int[] xTrail = new int[trailNum];
  int[] yTrail = new int[trailNum];
  int indexPosition = 0;

  float maxSpeed, maxForce; //for flocking

  int i_; //variable for checking collision
  Ball [] otherBalls;

  PImage glow;

  Ball (float _radius, int _i_, Ball [] _otherBalls) {
    location = new PVector(random(width), random(height));
    velocity = new PVector(1, 1);
    acceleration = new PVector(0, 0);
    radius = _radius;
    maxSpeed = 5;
    maxForce = 0.05;

    i_ = _i_;
    otherBalls = _otherBalls;

    glow = loadImage("glow.png");
  }

  //SEEK
  PVector seek (PVector target) {
    PVector direction = PVector.sub(target, location); //delta (change in postion)
    //direction.normalize();
    //direction.mult(maxSpeed);
    direction.setMag(maxSpeed); //can replace the two lines above

    //Steering
    //coordinates for turning
    PVector steer = PVector.sub(direction, velocity);
    steer.limit(maxForce);
    return steer;
  }

  //SEPARATION
  PVector seperate () { //the seperation is calculated
    float directionSeperation = 25.0f; //the f just makes it a float data type
    PVector steer = new PVector(0, 0); //the boids steering is initially zero
    int count = 0;

    //checks for every other boid
    for (int i = 0; i < ballAmount; i++) {
      float dist = PVector.dist(location, otherBalls[i].location); //the distance between boids

      if ((dist > 0) && (dist < directionSeperation)) { //if boids are with range...
        PVector difference = PVector.sub(location, otherBalls[i].location); //delta (change in position)
        difference.normalize(); //it is a unit vector of 1
        difference.div(dist); //the more distance, the less effect on steering
        steer.add(difference);
        count++; //the number of boids within range
      }
    }

    if (count > 0) {
      steer.div((float)count); //the other boids effect the steering
    }
    if (steer.mag() > 0) {
      steer.normalize(); //it is a unit vector of 1
      steer.mult(maxSpeed); //turn speed
      steer.sub(velocity); //change in velocity)
      steer.limit(maxForce); //steering strength limit
    }
    return steer; //
  }

  //ALIGNMENT
  PVector align () {
    float neighborDist = radius*25;
    PVector sum = new PVector(0, 0);
    int count = 0;

    //Add velocities.
    for (int i = 0; i < ballAmount; i++) {
      float dist = PVector.dist(location, otherBalls[i].location);
      if ((dist > 0) && (dist < neighborDist)) {
        sum.add(otherBalls[i].velocity);
        count++; //number of boids within range
      }
    }
    //Divide velocities for the average.
    if (count > 0) {
      sum.div((float)count);
      sum.normalize();
      sum.mult(maxSpeed);
      PVector steer = PVector.sub(sum, velocity); //change in velocities)
      steer.limit(maxForce);
      return steer; // boid aligns
    } else {
      return new PVector(0, 0); //boid does not align
    }
  }

  //COHESION
  PVector cohesion () {
    float neighborDist = radius*25;
    PVector sum = new PVector(0, 0);
    int count = 0;

    //the average location is found
    //add velocities
    for (int i = 0; i < ballAmount; i++) {
      float dist = PVector.dist(location, otherBalls[i].location);
      if ((dist > 0) && (dist < neighborDist)) {
        sum.add(otherBalls[i].location);
        count++;
      }
    }
    //divide for the average.
    if (count > 0) {
      sum.div(count);
      return seek(sum); //boid joins the group
    } else {
      return new PVector(0, 0); //boid does not join the group
    }
  }

  void flock () {
    PVector sep = seperate();
    PVector ali = align();
    PVector coh = cohesion();

    sep.mult(1.5);
    ali.mult(1.0);
    coh.mult(1.0);

    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
  }

  void ballCollision () {
    //check for collision with the other balls.
    //starts at 1 because it doesn't need to check itself
    for (int j = i_ + 1; j < ballAmount; j++) {
      //the distance between each ball.
      PVector delta = PVector.sub(otherBalls[j].location, location);
      float dist = sqrt(sq(delta.x) + sq(delta.y));
      if (dist < (radius + otherBalls[j].radius)) {
        //The normal plane
        PVector normalPlane = PVector.div(delta, dist);
        //The collision plane
        PVector midpoint = PVector.add(location, otherBalls[j].location);
        midpoint.div(2);
        //BOUNCE AWAY
        location.x = midpoint.x - radius * normalPlane.x;
        location.y = midpoint.y - radius * normalPlane.y;
        otherBalls[j].location.x = midpoint.x + otherBalls[j].radius * normalPlane.x;
        otherBalls[j].location.y = midpoint.y + otherBalls[j].radius * normalPlane.y;
        //
        float dVector = (velocity.x - otherBalls[j].velocity.x) * normalPlane.x + (velocity.y - otherBalls[j].velocity.y) * normalPlane.y;
        //
        PVector dVelocity = normalPlane;
        dVelocity.mult(dVector);
        //updated velocities
        //One ball will have velocity subtracted and the other added
        velocity.sub(dVelocity);
        otherBalls[j].velocity.add(dVelocity);
      }
    }
  }

  void applyForce (PVector force) {
    PVector friction = new PVector(velocity.x, velocity.y); //the velocity values are used to calculate friction
     friction.normalize(); //The length of the vector becomes 1
     float c = -0.2; //friction strength
     friction.mult(c); //friction
     force.add(friction);

    PVector f = PVector.div(force, radius);
    acceleration.add(f);
  }

  void movement () {
    velocity.add(acceleration);
    location.add(velocity);
    acceleration.mult(0);
  }

  void boundaryCollision () {
    if (location.x < radius) {
      location.x = radius;
      velocity.x *= -1;
    }
    if (location.x > width-radius) {
      location.x = width-radius;
      velocity.x *= -1;
    }
    if (location.y < radius) {
      location.y = radius;
      velocity.y *= -1;
    }
    if (location.y > height-radius) {
      location.y = height-radius;
      velocity.y *= -1;
    }
  }

  void display () {
    noStroke();
    fill(275, bgSatur, 75, 70);
    ellipse(location.x, location.y, radius*2, radius*2);
  }
}
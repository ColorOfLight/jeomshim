// range of bubble's size
final int bubbleSize[] = {5, 14};  // {minSize, maxSize}

// range of bubble's color
final int bubbleRed[] = {200, 255};
final int bubbleGreen[] = {200, 255};
final int bubbleBlue[] = {0, 255};


public class SummerBubble {
  //bubbleSystem bs = new bubbleSystem();
  ParticleSystem balloons = new ParticleSystem();
  
  SummerBubble() {
  }
  
  void update(MyKinect mk, PGraphics p) {
    if (mk == null) {
      if (mousePressed) {
        balloons.add(new Particle(mouseX, mouseY, p));
      }
    } else if (mk.ableGetLeft) {
      balloons.add(new Particle(mk.leftHand.x, mk.leftHand.y, p));
    }
    
    //bs.blow();
    balloons.run(p);
  }
}

//class Bubble {
//  float x;
//  float y;
//  int diameter = int(random(10,40));
//  float scalar = 0.2;
//  float angle = 0.0;
//  float speed = 0.01;
//  int age = 0;
//  float strokew = diameter/10;
//  float xv = -3+random(1,5);
//  float yv = -random(3);
//  float maxYV = 1;
//  PGraphics c;
  
//  Bubble(float xp, float yp, PGraphics p) {
//    x = xp;
//    y = yp;
//    c = p;
//   // s = tempS;
//    //diameter = tempDiameter;

//  }
  
//  void run(){
//    move();
//    display();
//  }
  
//   void move() {
//   x = x + xv + sin(angle)*scalar;
//   y += yv;
//   angle += speed;
//   age++;
//   if (age > 100) pop();
//  }
  
//  void display() {
//      c.ellipseMode(CENTER);

//      c.noFill();
//      c.stroke(255);
//      c.strokeWeight(strokew*0.5);
//      c.ellipse(x,y,diameter,diameter);
//      c.strokeWeight(strokew*1.5);
//      c.strokeCap(ROUND);
//      c.arc(x,y,diameter-15,diameter-15,5.65,6.56);
//      c.strokeWeight(strokew*1);
//      c.arc(x,y,diameter-15,diameter-15,0.79,1.16);
//  }
  
//  void pop(){
//      bubbles.remove(this);
//  }
  
//}

//ArrayList  bubbles = new ArrayList();


//class bubbleSystem{

//  int q = int(random(10,30));
  
//  void add(Bubble b){
//    bubbles.add(b);
//  }
  
//  void blow(){
//    for(int i = 0; i < bubbles.size(); i++){
//      Bubble b = (Bubble)bubbles.get(i);
//      b.run();
//    }
//  }
//}

class Particle
{
  float x = width/2;
  float y = height/2;
  float xv = -1+random(6);
  float yv = -random(4);
  float maxYV = 20;
  float gravity = 0.1;
  float friction = 1;
  float radius = random(bubbleSize[0], bubbleSize[1]);
  color c = color(random(bubbleRed[0], bubbleRed[1]),random(bubbleGreen[0], bubbleGreen[1]),random(bubbleBlue[0], bubbleBlue[1]));
  PGraphics ca;
   
  Particle(){  }
 
  Particle(float xp,float yp,PGraphics p)
  {
    x = xp;
    y = yp;
    ca = p;
    
  }
 
  Particle(float xp,float yp,PGraphics p,float xvel,float yvel)
  {
    this(xp, yp,p);
    xv = xvel;
    yv = yvel;
  }
 
  void run(PGraphics pg)
  {
    update();
    render(pg);
  }
 
  public void update()
  {
    if((yv < maxYV))
    {
      yv -= gravity*.2;
    }
    yv *= friction;

    y += yv;
    x += xv;
  }
 
  void render(PGraphics pg)
  {
    pg.noStroke();
    pg.fill(c);
    pg.ellipse(x,y,radius,radius*1.05);
  }
}

class ParticleSystem
{
  ArrayList particles = new ArrayList();
   
  ParticleSystem(){}
   
  void add(Particle p)
  {
    particles.add(p);
  }
   
  void removeAll()
  {
    particles.clear();
  }
   
  void run(PGraphics pg)
  {
    for(int i = 0; i < particles.size(); i++)
    {
      Particle p = (Particle)particles.get(i);
      p.run(pg);
    }
  }
}

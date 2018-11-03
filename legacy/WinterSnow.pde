// Number of snow plakes
final int MAX_PLAKES = 1200;

// Size of plakes
final float plakeSize = 4;

// Collision box size (커질수록 더 많은 범위의 눈이 움직임)
final int plakeCollision = 100;

ArrayList<Particle_c> plakes;

public class WinterSnow {
  
  WinterSnow() {
    plakes = new ArrayList<Particle_c>();
    for (int i = 0; i < MAX_PLAKES; i++ ) plakes.add( new Particle_c( i ) );
  }
  
  void update(MyKinect mk, PGraphics p) {
    if (mk == null) {
      for ( Particle_c pk : plakes ) pk.update(p, mousePressed, mouseX, mouseY);
    } else {
      for ( Particle_c pk : plakes ) pk.update(p, mk.ableGetLeft, mk.leftHand.x, mk.leftHand.y);
    }
  }
}

// A class which represents a particle in 2D space and takes care of
// all it's own colisions and dynamics.  
class Particle_c {
  PVector position;
  PVector velocity;
  int id;
  float r, m;

  // Variables required to track the rate of collision
  // this particle is experiencing.
  float p_collision;  // probability between 0.1 and 1
  float t_collision;  // time of last collision.
  
  // Constructor, id required to check against self-collision later.
  Particle_c( int _id ) {
     position = new PVector( random(0,width), random(0,height) );
     velocity = new PVector();
     //velocity = PVector.random2D();
     //velocity.mult(3);
     
     r = random(0.5,3);
     m = r *  0.1;
     id = _id;
     
     p_collision = 0.1;
     t_collision = millis();
  }

  

  // This one function follows an update procedure and completes
  // all steps to draw to the screen.
  void update(PGraphics p, boolean isPressed, float x, float y) {
    
    //if( id == 0 ) println("p_collision: " + p_collision );
    
    // Defines a new velocity if collision occurs.
    checkCollisionWithOthers();
    
    // Modifies velocity against window border
    checkBoundaryCollision();
    
    // Modifies velocity with respect to mouse click.
    checkAgainstMouse(isPressed, x, y);
    
    // Slowly reduces any velocity to zero.
    applyFriction();
    
    // Apply velocity for this update cycle.
    position.add(velocity);
    
    // Draw to screen.
    display(p);
  }
  
  // When the mouse is clicked, this object will check if it is
  // a radius of influence (50) and if so, moves away by adding
  // a distance proportional velocity.  
  void checkAgainstMouse(boolean isPressed, float x, float y) {
    
    if( isPressed ) {
      
       // Mouse vector.
       PVector mVect = new PVector( x, y );
       
       // Distance between object and mouse.
       float d = PVector.dist( position, mVect );
       
       // CHeck if in radius.
       if( d < plakeCollision ) { 
         
         // Subtract vectors to get a vector from origin (0,0)
         PVector bVect = PVector.sub( mVect, position );
         
         float theta;
         theta = atan2( mVect.y - position.y, mVect.x - position.x );
         
         // Inverse d, so that the further from the mouse,
         // the slower the additional velocity away. 
         d = 50 - d;
         velocity.x -= ( d * cos( theta) ) * 0.02;
         velocity.y -= ( d * sin( theta) ) * 0.02;
       }
          
    } 
  }
  
  // Simply multiply by a small number.
  void applyFriction() {
     velocity.mult(0.995);
  }
  
  // Use this objects ID number to check against all
  // other objects in the global array list.
  void checkCollisionWithOthers() {
     int i;
     boolean collision;
     
     // We use the probabilty p_collision to decide whether
     // to skip this operation.  It takes time for objects to
     // pass through one another, so we can afford to skip it
     // once in a while.  The probability is adjusted when a
     // collision detection is done.  Therefore, more collisions
     // creates a more probably chance of checking.
     if( random(0,1) > p_collision ) return; 
     
     
     // Run the collision check.  The most computationally expensive
     // part of this simulation.
     // Register if there was a collision to update the p_collision
     // probability.  
     collision = false;
     for( i = 0; i < plakes.size(); i++ ) {
        if( i != id ) {
           // If not self, grab instance of particle
           // and run through collision routine.
           Particle_c p = plakes.get(i);
           if( checkCollision( p ) ) {
              collision = true; 
           }
        }
     }
    
     // If there was a collision, increase the probability.
     if( collision ) {
        
        t_collision = millis();
        p_collision += 0.3;
        if( p_collision > 1 ) p_collision = 1.0;
      
     } else {
      
      // If more time has passed than the frame rate and we have
      // not had a collision, lower the probability of a collision
      // detection.
      if( millis() - t_collision > (1000 / frameRate ) ) {
          t_collision = millis();
          p_collision -= 0.1;
          if( p_collision < 0.3 ) p_collision = 0.3;
      }
     } 
  }
  

  // Alternative collision with screen, wrap around edges
  // instead.
  void wrapBoundaryCollision() {
     if( position.x > width ) position.x -= width;
     if( position.x < 0 ) position.x += width;
     if( position.y < 0 ) position.y += height;
     if( position.y > height ) position.y -= height; 
  }

  // Inverse the velocity depending on the screen
  // edge collision.
  void checkBoundaryCollision() {
    if (position.x > width-r) {
      position.x = width-r;
      velocity.x *= -1;
    } 
    else if (position.x < r) {
      position.x = r;
      velocity.x *= -1;
    } 
    else if (position.y > height-r) {
      position.y = height-r;
      velocity.y *= -1;
    } 
    else if (position.y < r) {
      position.y = r;
      velocity.y *= -1;
    }
  }

  boolean checkCollision(Particle_c other) {
    boolean collision;
    
    
    // get distances between the balls components
    PVector bVect = PVector.sub(other.position, position);

    // calculate magnitude of the vector separating the balls
    float bVectMag = bVect.mag();

    collision = false;    

    // If there is contact
    if (bVectMag < r + other.r) {
      
      collision = true;
      
      // heading() is not working on openprocessing.org
      // get angle of bVect
      //float theta  = bVect.heading();
      float theta;
      theta = atan2( other.position.y - position.y, other.position.x - position.x );
      
      
      // precalculate trig values
      float sine = sin(theta);
      float cosine = cos(theta);

      /* bTemp will hold rotated ball positions. You 
       just need to worry about bTemp[1] position*/
      PVector[] bTemp = {
        new PVector(), new PVector()
        };

        /* this ball's position is relative to the other
         so you can use the vector between them (bVect) as the 
         reference point in the rotation expressions.
         bTemp[0].position.x and bTemp[0].position.y will initialize
         automatically to 0.0, which is what you want
         since b[1] will rotate around b[0] */
        bTemp[1].x  = cosine * bVect.x + sine * bVect.y;
      bTemp[1].y  = cosine * bVect.y - sine * bVect.x;

      // rotate Temporary velocities
      PVector[] vTemp = {
        new PVector(), new PVector()
        };

      vTemp[0].x  = cosine * velocity.x + sine * velocity.y;
      vTemp[0].y  = cosine * velocity.y - sine * velocity.x;
      vTemp[1].x  = cosine * other.velocity.x + sine * other.velocity.y;
      vTemp[1].y  = cosine * other.velocity.y - sine * other.velocity.x;

      /* Now that velocities are rotated, you can use 1D
       conservation of momentum equations to calculate 
       the final velocity along the x-axis. */
      PVector[] vFinal = {  
        new PVector(), new PVector()
        };

      // final rotated velocity for b[0]
      vFinal[0].x = ((m - other.m) * vTemp[0].x + 2 * other.m * vTemp[1].x) / (m + other.m);
      vFinal[0].y = vTemp[0].y;

      // final rotated velocity for b[0]
      vFinal[1].x = ((other.m - m) * vTemp[1].x + 2 * m * vTemp[0].x) / (m + other.m);
      vFinal[1].y = vTemp[1].y;

      // hack to avoid clumping
      bTemp[0].x += vFinal[0].x;
      bTemp[1].x += vFinal[1].x;

      /* Rotate ball positions and velocities back
       Reverse signs in trig expressions to rotate 
       in the opposite direction */
      // rotate balls
      PVector[] bFinal = { 
        new PVector(), new PVector()
        };

      bFinal[0].x = cosine * bTemp[0].x - sine * bTemp[0].y;
      bFinal[0].y = cosine * bTemp[0].y + sine * bTemp[0].x;
      bFinal[1].x = cosine * bTemp[1].x - sine * bTemp[1].y;
      bFinal[1].y = cosine * bTemp[1].y + sine * bTemp[1].x;

      // update balls to screen position
      other.position.x = position.x + bFinal[1].x;
      other.position.y = position.y + bFinal[1].y;

      position.add(bFinal[0]);
      
      // add the overlap distance to stop clumping.
      float overlap = (r + other.r) - bVectMag;
      position.x -= cos( theta ) * overlap;
      position.x -= sin( theta ) * overlap;  

      // update velocities
      velocity.x = cosine * vFinal[0].x - sine * vFinal[0].y;
      velocity.y = cosine * vFinal[0].y + sine * vFinal[0].x;
      other.velocity.x = cosine * vFinal[1].x - sine * vFinal[1].y;
      other.velocity.y = cosine * vFinal[1].y + sine * vFinal[1].x;
      
    } 
    
    return collision;
  }


  void display(PGraphics p) {
    p.noStroke();
    p.fill(204);
    p.ellipse(position.x, position.y, r*plakeSize, r*plakeSize);
  }
}

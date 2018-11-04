
import processing.video.*;

// Variables
final boolean showUser = false; /* Show kinect user mask */
final boolean isKinect = false;
final boolean showText = false;
public final float GLOWING_SIZE = 20;
public final float SENSOR_PADDING = 30;

MyKinect mk;
int currentState;
int counterMillis = 0;

CenterInteraction ir1, ir4;
Ripples ir2;
Firework ir3;
GlowingHand mouseGH, leftGH, rightGH;

Movie myMovie, movie1, movie2, movie3, movie4, movie5, movie6;
Movie movieStar, movieOpening, movieFire;

void setup() {
  size(1920, 1080);
  noSmooth();

  if (isKinect) {
    mk = new MyKinect(this);
    leftGH = new GlowingHand(GLOWING_SIZE);
    rightGH = new GlowingHand(GLOWING_SIZE);
  } else {
    mk = null;
    mouseGH = new GlowingHand(GLOWING_SIZE);
  }

  currentState = 0;
  ir1 = new CenterInteraction(true);
  ir2 = new Ripples();
  ir3 = new Firework();
  ir4 = new CenterInteraction(false);

  movie1 = new Movie(this, "#1.mp4");
  movie2 = new Movie(this, "#2.mp4");
  movie3 = new Movie(this, "#3.mp4");
  movie4 = new Movie(this, "#4.mp4");
  movie5 = new Movie(this, "#5.mp4");
  movie6 = new Movie(this, "#6.mp4");
  movieOpening = new Movie(this, "#opening.mp4");
  movieStar = new Movie(this, "#star.mp4");
  movieFire = new Movie(this, "#fire.mp4");

  // myMovie = new Movie(this, "#2.mov");
  // myMovie.loop();
}

void draw() {
  background(0);

  if (currentState == 0) {
    image(movie1, 0, 0, 1920, 1080);
    movie1.loop();
    if ((isKinect && mk.ableGetLeft) || (!isKinect && mousePressed)) {
      currentState++;
      movie1.stop();
    }
  } else if (currentState == 1) {
    image(movie2, 0, 0, 1920, 1080);
    movie2.play();
    if (movie2.time() >= movie2.duration() - 0.5) {
      currentState++;
      movie2.stop();
    }
  } else if (currentState == 2) {
    image(movieOpening, 0, 0, 1920, 1080);
    movieOpening.loop();
    ir1.update(mk);
    if (ir1.didEnd()) {
      currentState++;
      movieOpening.stop();
    }
  } else if (currentState == 3) {
    image(movie3, 0, 0, 1920, 1080);
    movie3.play();
    if (movie3.time() >= movie3.duration() - 0.5) {
      currentState++;
      movie3.stop();
    }
  } else if (currentState == 4) {
    ir2.update(mk);
    if (counterMillis > 0) {
      if (millis() - counterMillis > 8 * 1000 ) {
        currentState++;
        counterMillis = 0;
      }
    }
    else if (ir2.didEnd()) {
     counterMillis = millis();
    }
  } else if (currentState == 5) {
    image(movie4, 0, 0, 1920, 1080);
    movie4.play();
    if (movie4.time() >= movie4.duration() - 0.5) {
      currentState++;
      movie4.stop();
    }
  } else if (currentState == 6) {
    image(movieFire, 0, 0, 1920, 1080);
    movieFire.loop();
    ir3.update(mk);
    if (counterMillis > 0) {
      if (millis() - counterMillis > 1 * 1000 ) {
        currentState++;
        counterMillis = 0;
        movieFire.stop();
      }
    }
    else if (ir3.didEnd()) {
      counterMillis = millis();
    }
  } else if (currentState == 7) {
    image(movie5, 0, 0, 1920, 1080);
    movie5.play();
    if (movie5.time() >= movie5.duration() - 0.5) {
      currentState++;
      movie5.stop();
    }
  } else if (currentState == 8) {
    image(movieStar, 0, 0);
    movieStar.loop();
    ir4.update(mk);
    if (counterMillis > 0) {
      if (millis() - counterMillis > 5 * 1000 ) {
        currentState++;
        counterMillis = 0;
        movieStar.stop();
      }
    }
    else if (ir4.didEnd()) {
      counterMillis = millis();
      println(counterMillis);
    }
  } else if (currentState == 9) {
    image(movie6, 0, 0, 1920, 1080);
    movie6.play();
    if (movie6.time() >= movie6.duration() - 0.5) {
      currentState++;
      movie6.stop();
    }
  }

  if (isKinect) {
    if (mk.ableGetLeft) leftGH.display(mk.leftHand.x, mk.leftHand.y);
    if (mk.ableGetRight) rightGH.display(mk.leftHand.x, mk.rightHand.y);
  } else {
    mouseGH.display(mouseX, mouseY);
  }

  // Show Log
  if (showText) {
    textSize(24);
    text("state: " + currentState, 10, 30); 
    fill(0, 102, 153);
  }
}

void movieEvent(Movie m) {
  m.read();
}

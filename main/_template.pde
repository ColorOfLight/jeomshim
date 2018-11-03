public class template {
  boolean isFinished;

  template() {
    this.isFinished = false;
  }

  void update(MyKinect mk) {
    if (mk != null) {
      move();
    } else {
      move(mousePressed, mouseX, mouseY);
    }
  }

  void move(boolean cond, float x, float y) {
    if (cond) {
      
    }
  }

  boolean didEnd() {
    return this.isFinished;
  }
}
import SimpleOpenNI.*;
import processing.serial.*;
import processing.core.PApplet;

public class MyKinect {
  SimpleOpenNI kinect;
  Serial myPort;
  PVector center, leftHand, rightHand;
  boolean ableGetLeft, ableGetRight, ableGetCenter;
  
  MyKinect(PApplet t) {  // give this in void setup()
    kinect = new SimpleOpenNI(t);
    kinect.setMirror(true);
    kinect.enableDepth();
    kinect.enableUser();
    
    //smooth();
    
    this.center = new PVector();
    this.leftHand = new PVector();
    this.rightHand = new PVector();
    this.ableGetLeft = false;
    this.ableGetRight = false;
    this.ableGetCenter = false;
  }
  
  void update() {
    kinect.update();
    IntVector userList = new IntVector();
    kinect.getUsers(userList);
    if (userList.size() > 0) {
      int userId = userList.get(0);
      
      PVector tmpLeft = _getHandAxes(userId, "left");
      PVector tmpRight = _getHandAxes(userId, "right");
      PVector tmpCenter = _getCenter(userId);
      
      if (tmpLeft == null) {
        this.ableGetLeft = false;
      } else {
        this.leftHand = tmpLeft;
        this.ableGetLeft = true;
      }
      
      if (tmpRight == null) {
        this.ableGetRight = false;
      } else {
        this.rightHand = tmpRight;
        this.ableGetRight = true;
      }
      
      if (tmpCenter != null) {
        this.ableGetCenter = true;
        this.center = tmpCenter;
      } else {
        this.ableGetCenter = false;
      }
    }
  }
  
  void drawUser(PGraphics p) {
    p.image(kinect.userImage(),0,0);
  }
  
  PVector _getHandAxes(int userId, String s) {
    int jointID = -1;
    if (s == "left") {
      jointID = SimpleOpenNI.SKEL_LEFT_HAND;
    } else if (s == "right") {
      jointID = SimpleOpenNI.SKEL_RIGHT_HAND;
    }
    PVector joint = new PVector();
    float confidence = kinect.getJointPositionSkeleton(userId, jointID,
    joint);
    println(confidence);
    if (confidence < 0.5) {
      return null;
    }
    PVector convertedJoint = new PVector();
    kinect.convertRealWorldToProjective(joint, convertedJoint);
    return convertedJoint;
  }
  
  PVector _getCenter(int userId) {
    PVector com = new PVector();
    PVector com2d = new PVector();
    if(kinect.getCoM(userId, com)){
      kinect.convertRealWorldToProjective(com,com2d);
      return com2d;
    }
    return null;
  }
  
}

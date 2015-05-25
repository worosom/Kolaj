import SimpleOpenNI.*;

public static int LAYERCOUNT = 8;
public static float WIDTH = 3300;
public static float HEIGHT = 3300;
  public static float HeightForB = -100;
  
Skeleton skeleton;
Layers coll;

PImage bg, ori;

float bRatio;

public void setup() {
  size(displayWidth, displayHeight, P2D);
  rectMode(CENTER);
  bg = loadImage("bg.png");
  ori = loadImage("ori.png");
  skeleton = new Skeleton(this);

  coll = new Layers(this, width, height);
}

public void draw() {
  image(bg, 0, 0, width, width);
  skeleton.update();

  coll.setHeadY(skeleton.getHeadY());
  if (skeleton.calibrated)
    bRatio = coll.drawLayers(skeleton.get());
  else {
    float size = coll.getScaleHeight();
    image(ori, width / 2.f - size*.8 / 2.f, height / 2.f - size*.8 / 2.f, 
    size*.8, size*.8);
  }

  if (DEBUG) {
    pushMatrix();
    translate(width / 2, height / 2);
    for (PVector p : skeleton.getNormalizedPosture ()) {
      ellipse(p.x, p.y, 10, 10);
    }
    for (PVector p : skeleton.getBody ()) {
      rect(p.x, p.y, 15, 15);
    }
    popMatrix();
    translate(0, 100);
    drawData();
  }
}

public void onNewUser(SimpleOpenNI curContext, int userId) {
  if (!skeleton.hasUser) {
    curContext.startTrackingSkeleton(userId);
  }
}

public void onLostUser(SimpleOpenNI curContext, int userId) {
  println("onLostUser - userId: " + userId);
  skeleton.loseUser(userId);
}

public void onVisibleUser(SimpleOpenNI curContext, int userId) {
  // println("onVisibleUser - userId: " + userId);
}

public void mouseMoved() {
  cursor(new PImage(0, 0));
}

void drawData() {
  textSize(50);
  text("hasUser: " + skeleton.hasUser, 0, 10);
  text("calibrated: " + skeleton.calibrated, 0, 60);
  text("userID: " + skeleton.calibrated, 0, 110);
  text("head Height: " + skeleton.skel[7], 0, 160);
  text("bRatio: " + bRatio, 0, 210);
}


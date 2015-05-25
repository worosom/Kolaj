  public static boolean DEBUG = false;
  public static float easeFactor = .1f;

class Skeleton {

  PApplet applet;
  SimpleOpenNI context;

  PVector[] body = new PVector[14];
  PVector neckB = new PVector(0, 0, 0);
  PVector[] skel = new PVector[14];
  PVector neck = new PVector(0, 0, 0);
  
  PVector[] positions = new PVector[14];

  boolean hasUser = false;
  int userID;
  boolean calibrated = false;

  int time, dtime;
  int calibrationDuration = 5000;

  Skeleton(PApplet applet) {
    this.applet = applet;
    resetSkeleton();

    context = new SimpleOpenNI(applet, SimpleOpenNI.RUN_MODE_MULTI_THREADED);
    if (context.isInit() == false) {
      PApplet.println("Can't init SimpleOpenNI, maybe the camera is not connected!");
      applet.exit();
      return;
    }

    context.enableDepth();

    context.enableUser();
  }

  private void resetSkeleton() {
    for (int i = 0; i < skel.length; i++) {
      skel[i] = new PVector(0, 0);
      body[i] = new PVector(0, 0);
      positions[i] = new PVector(0, 0);
    }
  }

  public int[] initTracking() {
    int[] userList = context.getUsers();
    for (int i = 0; i < userList.length; i++) {
      if (context.isTrackingSkeleton(userList[i])) {
        userID = i;
        PApplet.println("Tracking User " + userID + " now.");
        hasUser = true;
        time = applet.millis();
        break;
      }
    }
    return userList;
  }

  public void loseUser(int id) {
    int[] userList = context.getUsers();
    if (userList[userID] == id) {
      hasUser = false;
      time = 0;
      userID = 0;
      calibrated = false;
      resetSkeleton();
      PApplet.println("User lost.");
    }
  }

  void update() {
    context.update();
    int[] userList = context.getUsers();
    if (userList.length > 0) {
      if (!hasUser)
        initTracking();
      if (hasUser && applet.millis() - time > calibrationDuration
          && !calibrated) {
        updateSkeleton(userList, userID);
        for (int i = 0; i < skel.length; i++)
          body[i] = new PVector(skel[i].x, skel[i].y);
        neckB = new PVector(neck.x, neck.y);
        calibrated = true;
        PApplet.println("User calibrated.");
      }

      if (hasUser && calibrated) {
        if (context.isTrackingSkeleton(userList[userID])) {
          updateSkeleton(userList, userID);
          time = applet.millis();
        }
      }
    }
    if (DEBUG) {
      drawSkeleton();
    }
  }

  public float getHeadY() {
    return skel[7].y;
  }

  public PVector getNormalized(int i) {
    return PVector.sub(skel[i], neck);
  }

  public PVector[] getNormalized() {
    PVector[] re = new PVector[skel.length];
    for (int i = 0; i < skel.length; i++)
      re[i] = getNormalized(i);
    return re;
  }

  public PVector getNormalizedPosture(int i) {
    return PVector.sub(getNormalized(i), PVector.sub(body[i], neckB));
  }

  public PVector[] getNormalizedPosture() {
    PVector[] re = new PVector[skel.length];
    for (int i = 0; i < skel.length; i++)
      re[i] = getNormalizedPosture(i);
    return re;
  }

  public PVector getBody(int i) {
    return PVector.sub(body[i], neckB);
  }

  public PVector[] getBody() {
    PVector[] re = new PVector[body.length];
    for (int i = 0; i < body.length; i++)
      re[i] = getBody(i);
    return re;
  }
  
  public PVector[] get() {
    return positions;
  }

  void updateSkeleton(int[] userList, int userID) {
    context.getJointPositionSkeleton(userList[userID],
        SimpleOpenNI.SKEL_LEFT_SHOULDER, skel[0]);
    context.getJointPositionSkeleton(userList[userID],
        SimpleOpenNI.SKEL_LEFT_ELBOW, skel[1]);
    context.getJointPositionSkeleton(userList[userID],
        SimpleOpenNI.SKEL_LEFT_HAND, skel[2]);

    context.getJointPositionSkeleton(userList[userID],
        SimpleOpenNI.SKEL_RIGHT_SHOULDER, skel[3]);
    context.getJointPositionSkeleton(userList[userID],
        SimpleOpenNI.SKEL_RIGHT_ELBOW, skel[4]);
    context.getJointPositionSkeleton(userList[userID],
        SimpleOpenNI.SKEL_RIGHT_HAND, skel[5]);

    context.getJointPositionSkeleton(userList[userID],
        SimpleOpenNI.SKEL_TORSO, skel[6]);

    context.getJointPositionSkeleton(userList[userID],
        SimpleOpenNI.SKEL_HEAD, skel[7]);

    context.getJointPositionSkeleton(userList[userID],
        SimpleOpenNI.SKEL_LEFT_HIP, skel[8]);
    context.getJointPositionSkeleton(userList[userID],
        SimpleOpenNI.SKEL_RIGHT_HIP, skel[9]);

    context.getJointPositionSkeleton(userList[userID],
        SimpleOpenNI.SKEL_LEFT_KNEE, skel[10]);
    context.getJointPositionSkeleton(userList[userID],
        SimpleOpenNI.SKEL_RIGHT_KNEE, skel[11]);

    context.getJointPositionSkeleton(userList[userID],
        SimpleOpenNI.SKEL_LEFT_FOOT, skel[12]);
    context.getJointPositionSkeleton(userList[userID],
        SimpleOpenNI.SKEL_RIGHT_FOOT, skel[13]);

    context.getJointPositionSkeleton(userList[userID],
        SimpleOpenNI.SKEL_NECK, neck);
    positions = ease(positions, getNormalizedPosture(), easeFactor);
  }

  float ease(float a, float b, float r) {
    return a + (b - a) * r;
  }

  PVector[] ease(PVector[] a, PVector[] b, float r) {
    float d;
    for (int i = 0; i < a.length; i++) {
      a[i].x = ease(a[i].x, b[i].x, r);
      a[i].y = ease(a[i].y, b[i].y, r);
    }
    return a;
  }

  void drawSkeleton() {
    // draw the skeleton if it's available

    applet.image(context.userImage(), 0, 0);
    int[] userList = context.getUsers();
    for (int i = 0; i < userList.length; i++) {
      if (context.isTrackingSkeleton(userList[i])) {
        applet.stroke(255, 0, 0);
        drawSkeleton(userList[i]);
      }
    }
  }

  // draw the skeleton with the selected joints
  void drawSkeleton(int userId) {
    context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

    context.drawLimb(userId, SimpleOpenNI.SKEL_NECK,
        SimpleOpenNI.SKEL_LEFT_SHOULDER);
    context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER,
        SimpleOpenNI.SKEL_LEFT_ELBOW);
    context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW,
        SimpleOpenNI.SKEL_LEFT_HAND);

    context.drawLimb(userId, SimpleOpenNI.SKEL_NECK,
        SimpleOpenNI.SKEL_RIGHT_SHOULDER);
    context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER,
        SimpleOpenNI.SKEL_RIGHT_ELBOW);
    context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW,
        SimpleOpenNI.SKEL_RIGHT_HAND);

    context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER,
        SimpleOpenNI.SKEL_TORSO);
    context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER,
        SimpleOpenNI.SKEL_TORSO);

    context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO,
        SimpleOpenNI.SKEL_LEFT_HIP);
    context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP,
        SimpleOpenNI.SKEL_LEFT_KNEE);
    context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE,
        SimpleOpenNI.SKEL_LEFT_FOOT);

    context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO,
        SimpleOpenNI.SKEL_RIGHT_HIP);
    context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP,
        SimpleOpenNI.SKEL_RIGHT_KNEE);
    context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE,
        SimpleOpenNI.SKEL_RIGHT_FOOT);
  }
}


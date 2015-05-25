class Layers {
  

  PApplet applet;
  float width, height;
  private float scale;

  public float headY;


  private Layer[] layers = new Layer[LAYERCOUNT];

  Layers(PApplet applet, float width, float height) {
    this.applet = applet;
    this.width = width;
    this.height = height;
    scale = height / HEIGHT;
    for (int i = 0; i < LAYERCOUNT; i++)
      layers[i] = new Layer(i, applet.loadImage((LAYERCOUNT - i - 1)
          + ".png"), posA[LAYERCOUNT - i - 1], posB[order[LAYERCOUNT
          - i - 1]]);
  }

  public float drawLayers(PVector[] deflection) {
    float bRatio = HeightForB / headY;
    if (bRatio > 0)
      bRatio = 1.f / bRatio;
    else
      bRatio = 0;

    applet.g.pushMatrix();
    applet.g.translate(width / 2 - getScaleWidth() / 2.f, height / 2
        - getScaleHeight() / 2.f);
    int o;
    for (int i = 0; i < layers.length; i++) {
      if (bRatio == 0)
        o = i;
      else
        o = order[i];
      layers[o].draw(deflection[i], bRatio);
    }
    applet.g.popMatrix();

    return bRatio;
  }

  public Layer[] getLayers() {
    return layers;
  }

  public float getScaleWidth() {
    return WIDTH * scale;
  }

  public float getScaleHeight() {
    return HEIGHT * scale;
  }

  public void setHeadY(float in) {
    headY = ease(headY, in, 0.3f);
  }
  
  public float ease(float a, float b, float r) {
    return a + (b-a)*r;
  }

  public class Layer {
    private int id;
    private float[] posA, posB;
    private PVector pos;
    private PImage img;
    private float imgWidth, imgHeight;

    public Layer(int id, PImage img, float[] posA, float[] posB) {
      this.id = id;
      this.img = img;
      this.posA = posA;
      this.posB = posB;
      imgWidth = img.width * scale;
      imgHeight = img.height * scale;
      pos = new PVector(posA[0], posA[1]);
    }

    public void draw(PVector deflection, float bRatio) {
      pos = getPos(bRatio);
      applet.g.pushMatrix();
      applet.g.translate(deflection.x * (1.f - bRatio), deflection.y
          * (1.f - bRatio));
      applet.g.image(img, pos.x - imgWidth / 2.f,
          pos.y - imgHeight / 2.f, imgWidth, imgHeight);
      applet.g.popMatrix();
    }

    private PVector getPos(float bRatio) {
      if (bRatio > 1)
        bRatio = 1;
      float x = posA[0] * scale * (1.f - bRatio) + posB[0] * scale
          * bRatio;
      float y = posA[1] * scale * (1.f - bRatio) + posB[1] * scale
          * bRatio;
      return new PVector(x, y);
    }

    public int getID() {
      return id;
    }
  }


}

  public static float[][] posA = new float[][] {

  { 1685, 1680 },

  { 1616, 1645 },

  { 1697, 1658 },

  { 1665, 1608 },

  { 1654, 1605 },

  { 1661, 1620 },

  { 1628, 1627 },

  { 1639, 1645 },

  { 1656, 1632 },

  { 1806, 2142 } };

  public static float[][] posB = new float[][] {

  { -386, 3879 },

  { 3276, -892 },

  { 1291, 1558 },

  { 1327, 1565 },

  { 1363, 1550 },

  { -178, -148 },

  { 1321, 1550 },

  { 3434, 3716 },

  { 1650, 1650 } };

  // public static int[] order = new int[] {
  // 7,
  // 4,
  // 5,
  // 0,
  // 3,
  // 2,
  // 1,
  // 6 };
  //
  public static int[] order = new int[] { 4, 1, 2, 3, 6, 5, 0, 7 };

  // public static int[] order = new int[] {
  // 7,
  // 0,
  // 5,
  // 6,
  // 3,
  // 2,
  // 1,
  // 4};

  // Test Positions
  // public static float[][] posA = new float[][] {
  // // 0
  // { 827, 908 },
  // // 1
  // { 1103, 906 },
  // // 2
  // { 1389, 908 },
  // // 3
  // { 1683, 908 },
  // // 4
  // { 1969, 911 },
  // // 5
  // { 2265, 908 },
  // // 6
  // { 2558, 1263 },
  // // 7
  // { 2845, 1618 },
  // // 8
  // { 3136, 1974 },
  // // 9
  // { 963, 2398 },
  // // 10
  // { 1440, 2389 },
  // // 11
  // { 2027, 2396 },
  // // 12
  // { 2537, 2753 },
  // // 13
  // { 3061, 3108 } };


public class GoKart {
  public static final int MAX_BARS = 8;
  private String mColor;
  private int mBarsCount;
  
  public GoKart(String color) {
    mColor = color;
    mBarsCount = 0;
  }
  
  public String getColor() {
    return mColor;
  }

  public void drive() {
    drive(1);
  }

  public void drive(int laps) {
    if(laps>mBarsCount){
      throw new IllegalArgumentException("Not enough battery remains.");
    }
    // Other driving code omitted for clarity purposes
    mBarsCount -= laps;
  }
  
  public void charge() {
    while (!isFullyCharged()) {
      mBarsCount++;
    }
  }
  
  public boolean isBatteryEmpty() {
    return mBarsCount == 0;
  }

  public boolean isFullyCharged() {
    return mBarsCount == MAX_BARS;
  }

}
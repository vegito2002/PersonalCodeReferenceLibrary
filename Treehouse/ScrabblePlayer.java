public class ScrabblePlayer {
  private String mHand;

  public ScrabblePlayer() {
    // mHand = "";
    mHand = "sreclhak";
  }

  public String getHand() {
   return mHand;
  }

  public void addTile(char tile) {
    // Adds the tile to the hand of the player
    mHand += tile;
  }


  public int getTileCount(char tile){
    int result=0;
    for(char i:mHand.toCharArray()){
        if(i==tile){
            result++;
        }
    }
    return result;
  }
  public boolean hasTile(char tile) {
   return mHand.indexOf(tile) > -1;
  }
}
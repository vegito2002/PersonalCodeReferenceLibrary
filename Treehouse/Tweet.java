public class Tweet {
	public static final int MAX_LETTER=140;
  private String mText;
    
  public Tweet(String text) {
    mText = text;
  }

public int getRemainingCharacters(){
	return MAX_LETTER-mText.length();
}

  public String getText() {
    return mText;
  }

}
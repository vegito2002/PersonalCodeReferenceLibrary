import com.example.BlogPost;

public class TypeCastChecker {
  /***************
  I have provided 2 hints for this challenge.
  Change `false` to `true` in one line below, then click the "Check work" button to see the hint.
  NOTE: You must set all the hints to false to complete the exercise.
  ****************/
  public static boolean HINT_1_ENABLED = false;
  public static boolean HINT_2_ENABLED = false;
                              
  public static String getTitleFromObject(Object obj) {
    // Fix this result variable to be the correct string.
    String result = "";
    if (obj instanceof String) {
      result = (String) obj;
    } else if (obj instanceof BlogPost) {
      result= ((BlogPost) obj).getTitle();
    }
    return result;
  }
}
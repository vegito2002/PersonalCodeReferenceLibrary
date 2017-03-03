import java.util.Arrays;
import java.util.Date;

import com.teamtreehouse.Treet;
import com.teamtreehouse.Treets;


public class Example {

  public static void main(String[] args) {
    Treet[] treets = Treets.load();
    System.out.printf("There are %d treets. %n",
                     treets.length);
    Treet originalTreet = treets[0];
    System.out.println("Hashtags:");
    for (String hashtag : originalTreet.getHashTags()) {
      System.out.println(hashtag);
    }
  }

}
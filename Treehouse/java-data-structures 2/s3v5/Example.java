import java.util.Arrays;
import java.util.Date;
import java.util.HashSet;
import java.util.Set;
import java.util.TreeSet;

import com.teamtreehouse.Treet;
import com.teamtreehouse.Treets;


public class Example {

  public static void main(String[] args) {
    Treet[] treets = Treets.load();
    System.out.printf("There are %d treets. %n",
                     treets.length);
    Set<String> allHashTags = new HashSet<String>();
    Set<String> allMentions = new TreeSet<String>();
    for (Treet treet : treets) {
      allHashTags.addAll(treet.getHashTags());
      allMentions.addAll(treet.getMentions());
    }
    System.out.printf("Hash tags: %s %n", allHashTags);
    System.out.printf("Mentions: %s %n", allMentions);
  }

}
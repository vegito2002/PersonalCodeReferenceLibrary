import java.util.Arrays;
import java.util.Date;

import com.teamtreehouse.Treet;
import com.teamtreehouse.Treets;


public class Example {

  public static void main(String[] args) {
    Treet[] treets = Treets.load();
    System.out.printf("There are %d treets. %n",
                     treets.length);
  }

}
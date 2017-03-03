public class Thing {
  public static final String ANSI_RESET = "\u001B[0m";
  public static final String ANSI_RED = "\u001B[31m";
  public static final String ANSI_GREEN = "\u001B[32m";
  
  public static void explore(String assumption,
                             boolean result) {
    StringBuilder sb = new StringBuilder();
    if (result) {
      sb.append(String.format("%sYAY!%s", 
                             ANSI_GREEN, 
                             ANSI_RESET));
    } else {
      sb.append(String.format("%sWAT???!%s",
                             ANSI_RED,
                             ANSI_RESET));
    }
    sb.append("  ");
    sb.append(assumption);
    if (!result) {
      sb.append(" (Your assumption is incorrect)");
    }
    System.out.println(sb.toString());
 }
  
  public static void main(String[] args) {
    // Your assumptions here
    int firstNumber = 12;
    int secondNumber = 12;
    explore("Primitives use double equals", firstNumber==secondNumber);
    Object firstObject = new Object();
    Object secondObject = new Object();
    explore("Objects references use double equals to check if they refer to the same object in memory, seemingly equal objects are not equal", firstObject!=secondObject);
    Object sameObject=firstObject;
    explore("Object references mmust refer to the same object to use double equals", firstObject==sameObject);
    String firstString= "Craig";
    String secondString= "Craig";
    explore("String literals are actually referring to the same object", firstString == secondString);
    String differentString=new String("Craig");
    explore("String objects that contain the same characters but point to different objects cannot use double equals", firstString!=differentString);
    String anotherString = new String ("Craig");
    explore("String Interning adds to the same String Pool where literals live, so you get back the same reference", anotherString.intern()==firstString);
    explore("ALl objects should use equals to check quality", firstString.equals(differentString)); //firstString is a String literal and differentString is created with the constructor, so they are in different pools
    
  }
}
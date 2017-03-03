public class ConferenceRegistrationAssistant {
  
  public int getLineFor(String lastName) {
    /* If the last name is between A thru M send them to line 1
       Otherwise send them to line 2 */
    // int line = 0;

    // return line;
       char lastNameInitial=lastName.charAt(0);
       return lastNameInitial<='M'?1:2;
  }

}
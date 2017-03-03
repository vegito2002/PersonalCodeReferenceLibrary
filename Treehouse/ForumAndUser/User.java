public class User {
	private String mFirstName;
	private String mLastName;
    
  public User(){
  	mFirstName="";
  	mLastName="";
  }

  public User(String firstName, String lastName) {
    // TODO:  Set the private fields here
    mFirstName=firstName;
    mLastName=lastName;
  }

  public String getFirstName(){
  	return mFirstName;
  }

  public String getLastName(){
  	return mLastName;
  }
}
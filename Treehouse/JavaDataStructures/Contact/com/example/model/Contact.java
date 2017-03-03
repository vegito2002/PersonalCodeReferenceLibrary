package com.example.model;

import java.util.Map;
import java.util.Set;
import java.util.HashMap;

public class Contact {
  private String mFirstName;
  private String mLastName;
  private Map<String, String> mContactMethods;
  
  public Contact(String firstName, String lastName) {
    mFirstName = firstName;
    mLastName = lastName;
    /* This stores contact methods by name
     * eg:  "phone" => "(555) 555-1234"
     */
    mContactMethods = new HashMap<String, String>();
  }

  public void addContactMethod(String method, String value) {
    // TODO: Add to the contact method map
    mContactMethods.put(method,value);
  }

  /**
   * Returns the available contact methods.  eg: phone, pager,
   *
   * @return The name of the contact methods that are available
   */
  public Set<String> getAvailableContactMethods() {
    // FIXME: This should return the current contact method names.
    return mContactMethods.keySet();
  }

  /**
   * Returns the value for the contact method if it exists, 
   *
   * @param methodName  The name of the contact method to look up.
   * @return The name of the contact methods that are available
   */
  public String getContactInfo(String methodName) {
    // FIXME: return the value for the passed in *methodName*
    return mContactMethods.get(methodName);
  }

  public String getFirstName() {
    return mFirstName;
  }

  public String getLastName() {
    return mLastName;
  }

}
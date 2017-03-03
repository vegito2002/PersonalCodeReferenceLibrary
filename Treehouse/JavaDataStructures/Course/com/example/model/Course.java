package com.example.model;

import java.util.List;
import java.util.Set;
import java.util.HashSet;

public class Course {
  private String mTitle;
  private Set<String> mTags;
                     
  public Course(String title) {
    mTitle = title;
    // TODO: initialize the set mTags
    mTags = new HashSet<String>();
  }

  public void addTag(String tag) {
    // TODO: add the tag
    mTags.add(tag);
  }

  public void addTags(List<String> tags) {
    // TODO: add all the tags passed in
    for (String eachTag: tags) {
      mTags.add(eachTag);
    }
  }

  public boolean hasTag(String tag) {
    // TODO: Return whether or not the tag has been added
    return mTags.contains(tag);
  }

  public String getTitle() {
    return mTitle;
  }
    
}
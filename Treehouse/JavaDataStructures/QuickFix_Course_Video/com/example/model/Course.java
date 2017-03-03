package com.example.model;

import java.util.List;

public class Course {
  private String mName;
  private List<Video> mVideos; 
    
  public Course(String name, List<Video> videos) {
    mName = name;
    mVideos = videos;
  }

  public String getName() {
    return mName;
  }

  public List<Video> getVideos() {
    return mVideos;
  }

}
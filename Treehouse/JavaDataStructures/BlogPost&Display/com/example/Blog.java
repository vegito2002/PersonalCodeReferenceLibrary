package com.example;

import java.util.List;
import java.util.Set;
import java.util.TreeSet;
import java.util.Map;
import java.util.HashMap;

public class Blog {
  List<BlogPost> mPosts;
  
  public Blog(List<BlogPost> posts) {
    mPosts = posts;
  }

  public List<BlogPost> getPosts() {
    return mPosts;
  }

  public Set<String> getAllAuthors() {
    Set<String> authors = new TreeSet<>();
    for (BlogPost post: mPosts) {
      authors.add(post.getAuthor());
    }
    return authors;
  }

  public Map<String,Integer> getCategoryCounts(){
  	Map<String, Integer> results = new HashMap<String, Integer>();
  	for (BlogPost eachPost: mPosts) {
  		Integer count = results.get(eachPost.getCategory());
  		if (count == null){
  			count = 0;
  		}
  		count ++;
  		results.put(eachPost.getCategory(), count);
  	}
  	return results;
  }
}
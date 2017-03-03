public class Forum {
  private String mTopic;

  public Forum(String arg){
    mTopic=arg;
  }
  
  public String getTopic() {
      return mTopic;
  }
    
  public void addPost(ForumPost post) {
       // When all is ready uncomment this...
      System.out.printf("New post from %s %s about %s.\n",
                         post.getAuthor().getFirstName(),
                         post.getAuthor().getLastName(),
                         post.getTitle());
      
  }
}
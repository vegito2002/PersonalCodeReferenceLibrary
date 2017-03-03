public class ForumPost {
  private User mAuthor;
  private String mTitle;
  private String mDescription;

  public ForumPost(){
    mAuthor=new User();
    mTitle="";
    mDescription="";
  }

  public ForumPost(User author, String title, String description){
    mAuthor=author;
    mTitle=title;
    mDescription=description;
  }

  public String getDescription(){
    return mDescription;
  }

  public User getAuthor() {
    return mAuthor;
  }

  public String getTitle() {
    return mTitle;
  }

  // TODO: We need to expose the description
}
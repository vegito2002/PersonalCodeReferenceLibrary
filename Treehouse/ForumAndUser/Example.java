public class Example {

  public static void main(String[] args) {
    System.out.println("Starting forum example...");
    if (args.length < 2) {
       System.out.println("first and last name are required. eg:  java Example Craig Dennis");
       System.exit(0);
    }

    Forum forum = new Forum("Topic");
    // Take the first two elements passed args
    User author = new User(args[0],args[1]);
    // Add the author, title and description
    ForumPost post = new ForumPost(author, "Title", "Description");
    forum.addPost(post);
  }
}
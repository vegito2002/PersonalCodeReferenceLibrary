public class ShoppingCart {

  public void addItem(Product item, int quantity) {
    System.out.printf("Adding %d of %s to the cart.%n", quantity, item.getName());
    /* Other code omitted for clarity. Please imagine
       lots and lots of code here. Don't repeat it. 
    */
  }
  public void addItem(Product item) {
    addItem(item,1);
    }
}


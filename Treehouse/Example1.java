public class Example1 {
    
  public static void main(String[] args) {
    ShoppingCart cart = new ShoppingCart();
    Product pez = new Product("Cherry PEZ refill (12 pieces)");
    cart.addItem(pez, 5);
    /* Since a quantity of 1 is such a common argument when adding a product to the cart,
     * your fellow developers have asked you to make the following code work, as well as keeping
     * the ability to add a product and a quantity.
     */
    Product dispenser = new Product("Yoda PEZ dispenser");
    /* Uncomment the line following this comment,
       after adding a new method using method signatures,
       to solve their request in ShoppingCart.java
    */
    // cart.addItem(dispenser);
  }

}
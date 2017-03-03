package CustomerSupport;

import java.util.ArrayDeque;
import java.util.Queue;

public class CallCenter {
  Queue<CustomerSupportRep> mSupportReps;
  
  public CallCenter(Queue<CustomerSupportRep> queue) {
    mSupportReps = queue;
  }

  public void acceptCustomer(Customer customer) {
    CustomerSupportRep csr;
    /********************************************
     * TODO (1) 
     * Wait until there is an available rep in the queue.
     * While there is not one available, playHoldMusic
     * HINT: That while assignmentcheck loop syntax we used to 
      *      read files seems pretty similar
     ********************************************
     */
    while ((csr = mSupportReps.poll()) == null) {
      playHoldMusic();
    }

    /********************************************
     * TODO (2) 
     * After we have assigned the rep, call the 
     * assist method and pass in the customer
     ********************************************
     */
    csr.assist(customer);


    /********************************************
     * TODO (3) 
     * Since the customer support rep is done with
     * assisting, put them back into the queue.
     ********************************************
     */
    mSupportReps.add(csr);
    
  }

  public void playHoldMusic() {
    System.out.println("Smooooooth Operator.....");
  }
 
}
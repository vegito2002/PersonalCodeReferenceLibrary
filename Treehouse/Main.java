public class Main {
    public static void main(String[] args) {
        GoKart kart = new GoKart("yellow");
        if (kart.isBatteryEmpty()) {
          System.out.println("The battery is empty");
        }
        try{
        	kart.drive(2);
        }catch(IllegalArgumentException iae){
        	System.out.printf("The error message is %s\n",iae.getMessage());
        }
    }
}
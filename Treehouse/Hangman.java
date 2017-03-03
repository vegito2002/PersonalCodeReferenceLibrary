// import java.io;


public class Hangman {
    
    public static void main(String[] args) {
    	if (args.length==0) {
    		System.out.println("Please enter a word");
    		System.exit(0);
    	}
        Game game=new Game(args[0]);
        Prompter prompter=new Prompter(game);
        // prompter.displayProgress();
        // boolean isHit=prompter.promptForGuess();
        // if(isHit){
        // 	System.out.println("We got a hit!");
        // }else{
        // 	System.out.println("Whoops that was a miss.");
        // }
        // prompter.displayProgress();
        prompter.play();
    }

}
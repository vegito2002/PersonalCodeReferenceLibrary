import java.io.Console;



public class Prompter{
	private Game mGame;

	public Prompter(Game game){
		mGame=game;
	}

	public void play () {
		while(mGame.getRemainingTries() > 0 && !mGame.isSolved()){
			displayProgress();
			promptForGuess();
		}
		if (mGame.isSolved()){
			System.out.printf("Congratulations you won with %d tries remaining",mGame.getRemainingTries());
		}else {
			System.out.printf("Bummer the word was %s.   :(\n",mGame.getAnswer());
		}
	}

	public void testPrompter(){
		System.out.println("1");
	}
	public boolean promptForGuess(){
		Console console=System.console();
		boolean isHit=false;
		boolean isValidGuess=false;
		while (!isValidGuess){
			String guessAsString=console.readLine("Enter a letter:   ");
			// char guess=guessAsString.charAt(0);
			try{
				isHit = mGame.applyGuess(guessAsString);
				//下面的代码是exception不被trigger的时候需要execute的内容;
				isValidGuess=true;
			}catch(IllegalArgumentException iae){
				console.printf("%s.   Please try again.\n", iae.getMessage());
			}
		}
		return isHit;
		// return mGame.applyGuess(guess);
	}

	public void displayProgress(){
		System.out.printf("You have %d tries left to solve:   %s\n", mGame.getRemainingTries(), mGame.getCurrentProgress());
	}
}
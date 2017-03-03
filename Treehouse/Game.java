public class Game{
	public static final int MAX_MISSES=7;
	private String mAnswer;
	private String mhits;
	private String mMisses;

	public Game(String answer){
		mAnswer=answer;
		mhits="";
		mMisses="";
	}

	public boolean applyGuess(String letters){
		//这里的内容就是保证applyGuess的parameter不是null,但是为什么这个不能在下面char版本的applyGuess里面进行??
		//因为Game.applyGuess的parameter是通过Prompter.promptForGuess传过来的,而promptForGuess获得的方式是readLine,获得的是String.
		//在这之前的做法是,让promptForGuess直接获得String,然后处理出来一个char,然后调用Game的只能take char的applyGuess;
		//现在就可以直接take String, and the argument does not have to be preprocessed by prompter.
		if (letters.length()==0){
			throw new IllegalArgumentException("No letter found");
		}
		// char firstLetter=letter.charAt(0);
		return applyGuess(letters.charAt(0));
	}

	private char validateGuess(char letter){
		if (!Character.isLetter(letter)){
			throw new IllegalArgumentException("A letter is required");
		}
		letter=Character.toLowerCase(letter);
		if (mMisses.indexOf(letter)>=0 || mhits.indexOf(letter)>=0) {
			throw new IllegalArgumentException(letter + " has already been guessed");
		}
		return letter;
	}

	public boolean applyGuess(char letter){
		letter = validateGuess(letter);
		boolean isHit=mAnswer.indexOf(letter)>=0;
		if(isHit){
			mhits+=letter;
		}else{
			mMisses+=letter;
		}
		return isHit;
	}

	public String getAnswer(){
		return mAnswer;
	}

	public String getCurrentProgress(){
		//Think about what kind of return value you're gonna construct.
		String progress="";
		for(char letter:mAnswer.toCharArray()){
			char display='-';
			if(mhits.indexOf(letter)>=0){
				display=letter;
			}
			progress+=display;
		}
		return progress;
	}
	public void testGame(){
		System.out.println("1");
	}

	public boolean isSolved(){
		return getCurrentProgress().indexOf('-')==-1;
	}

	public int getRemainingTries(){
		return MAX_MISSES- mMisses.length();
	}

}
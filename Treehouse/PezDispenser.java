public class PezDispenser {
	public static final int MAX_PEZ=12;
	private String mCharacterName;
	private int mPezCount;

	public PezDispenser(String characterName){
		mCharacterName=characterName;
		mPezCount=0;
	}

	public String getCharacterName(){
		return mCharacterName;
	}
	public void load(){
		load(MAX_PEZ);//无参函数直接delegate给有参函数;
	}
	public void load(int PezAmount){
		int newAmount=mPezCount+PezAmount;
		if(newAmount>MAX_PEZ){
			throw new IllegalArgumentException("Too many PEZ!!!");
		}
		mPezCount=newAmount;
	}

	public boolean dispense(){
		boolean wasDispensed=false;
		if(!isEmpty()){
			mPezCount--;
			wasDispensed=true;
		}
		return wasDispensed;
	}


	public boolean isEmpty(){
		return mPezCount==0;
		//return isActuallyEmtpy;
	}
}
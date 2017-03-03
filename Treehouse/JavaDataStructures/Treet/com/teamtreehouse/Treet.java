package com.teamtreehouse;

import java.util.Date;
import java.io.Serializable;
import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;

public class Treet implements Comparable<Treet>, Serializable {
	private boolean mIsBreak=true;

	private static final long serialVersionUID = -8849367543499888973L;

	private final String mAuthor;
	private final String mDescription;
	private Date mCreationDate;

	public Treet (String author, String description, Date creationDate){
		mAuthor=author;
		mDescription=description;
		mCreationDate=creationDate;
	}

	@Override
	public int compareTo(Treet other){
		// Treet other =(Treet) obj;
		if (equals(other)) {
			return 0;
		}
		int dateCmp = mCreationDate.compareTo(other.mCreationDate);
		if (dateCmp==0){
			return mDescription.compareTo(other.mDescription); //you can see other.mDescription because you're in the same class;
		}
		return dateCmp;
	}
	public String getAuthor(){
		return mAuthor;
	}

	public String getDescription(){
		return mDescription;
	}

	public Date getCreationDate(){
		return mCreationDate;
	}

	@Override
	public String toString(){
		// return "Treet:   \"" + mDescription + "\" - @ " + mAuthor + " on " + mCreationDate;
		return String.format("Treet:   \"%s\" by %s on %s",mDescription,mAuthor,mCreationDate);
	}

	public List<String> getWords(){
		String[] someArray= mDescription.toLowerCase().split("[^\\w#@']+");
		return Arrays.asList(someArray);
	}


	public List<String> getHashTags(){
		return getWordsPrefixedWith("#");
	}


	public List<String> getMentions(){
		return getWordsPrefixedWith("@");
	}

	private List<String> getWordsPrefixedWith(String prefix){
		List<String> results = new ArrayList<String>();
		for (String i: getWords()) {
			if (i.startsWith(prefix)) {
				results.add(i);
			}
		}
		return results;
	}
	 
}
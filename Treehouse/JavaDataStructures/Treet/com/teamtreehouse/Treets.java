package com.teamtreehouse;

import java.io.*;

public class Treets {
	// private Treet mTreet;


	public static void save(Treet[] treets){  //typically, static method does not return anything. But I think there are exceptions.
		try (
			FileOutputStream fos = new FileOutputStream("treets.ser");
			ObjectOutputStream oos = new ObjectOutputStream(fos);
			){
			oos.writeObject(treets);
		}catch(IOException ioe){
			System.out.println("Problem Saving Treets");
			ioe.printStackTrace();
		}
	}

	public static Treet[] load(){
		Treet[] treets = new Treet[0];
		try (
			FileInputStream fis = new FileInputStream("treets.ser");
			ObjectInputStream ois = new ObjectInputStream(fis);
			){
			treets = (Treet[]) ois.readObject();
		}catch(IOException ioe){
			System.out.println("Error reading file");
			ioe.printStackTrace();
		}catch(ClassNotFoundException cnfe){
			System.out.println("Error loading treets");
			cnfe.printStackTrace();
		}
		return treets;
	}
}
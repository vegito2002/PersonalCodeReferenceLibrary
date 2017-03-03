package com.teamtreehouse;

import com.teamtreehouse.model.SongBook;
import com.teamtreehouse.model.Song;

import java.io.IOException;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;
import java.util.Queue;
import java.util.ArrayDeque;

public class KaraokeMachine {
	private SongBook mSongBook;
	private BufferedReader mReader;
	private Map<String, String> mMenu;
	// private Queue mSongQueue;
	private Queue<Song> mSongQueue;

	public KaraokeMachine (SongBook songBook) {
		mSongBook = songBook;
		mReader = new BufferedReader(new InputStreamReader(System.in));
		mMenu = new HashMap<String, String>();
		mSongQueue = new ArrayDeque<Song>();
		mMenu.put("add", "Adding a new song to the machine");
		mMenu.put("choose","Choose a song to sing");
		mMenu.put("quit", "Exiting the program");
	}

	private String promptAction() throws IOException {
		System.out.printf("There are %d songs available and %d in the queue. %n Your options are :   %n", mSongBook.getSongCount(), mSongQueue.size());
		for (Map.Entry option : mMenu.entrySet()) {
			System.out.printf("%s --- %s   %n", option.getKey(), option.getValue());
		}
		System.out.print("Enter your action:     ");
		String choice = mReader.readLine();
		return choice.trim().toLowerCase();
	}

	public void run(){
		String choice = "";
		do{
			try{
				choice = promptAction();
				switch (choice) {
					case "add":
						Song song = promptNewSong();
						mSongBook.addSong(song);
						System.out.printf("Added the song %s.    %n%n", song);
						break;
					case "choose":
						String artist = promptArtist();
						Song songForArtist = promptSongForArtist(artist);
						mSongQueue.add(songForArtist);
						break;
					case "quit":
						System.out.println("Thanks for playing");
						break;
					default:
						System.out.printf("Unknown choice: %s.     Try again  %n%n%n",choice);
						// break;
				}
			}catch(IOException ioe){
				System.out.printf("Problem with input.  ");
				ioe.printStackTrace();
			}
		}while(!choice.equals("quit"));
	}

	private Song promptNewSong() throws IOException{
		System.out.print("Enter the artist name: ");
		String artist = mReader.readLine();
		System.out.print("Enter the song title: ");
		String title = mReader.readLine();
		System.out.print("Enter the video URL: ");
		String videoUrl = mReader.readLine();
		return new Song(artist, title, videoUrl);
	}

	private int promptForIndex(List<String> options) throws IOException {
		int counter = 1;
		for (String eachOption : options ){
			System.out.printf("%d.)    %s %n", counter, eachOption);
			counter++;
		}
		System.out.print("Enter your choice:  ");
		String optionAsString = mReader.readLine();
		int choice = Integer.parseInt(optionAsString.trim());
		System.out.printf("Your choice is:   %d  %n", choice);
		return choice -1 ;
		// return Integer.parseInt(optionAsString.trim())-1;
	}

	private String promptArtist() throws IOException {
		System.out.println("Available artists are:    ");
		List<String> artists = new ArrayList<>(mSongBook.getArtists());
		// Collections.sort(artists);
		// for (String eachArtist : artists) {
		// 	System.out.printf("")
		// }
		int choice = promptForIndex(artists);
		return artists.get(choice);
	}

	private Song promptSongForArtist(String artist) throws IOException {
		List<Song> songsForThisArtist = mSongBook.getSongsByArtist(artist);
		List<String> songTitlesForThisArtist = new ArrayList<>();
		for (Song eachSong : songsForThisArtist) {
			songTitlesForThisArtist.add(eachSong.getTitle());
		}
		System.out.printf("We have %d songs for %s. Enter your choice of song:   %n", songTitlesForThisArtist.size(), artist);
		int chosenIndex = promptForIndex(songTitlesForThisArtist);
		return songsForThisArtist.get(chosenIndex);
	}

	public void playNext(){
		Song nextSong = mSongQueue.poll();
		if (nextSong == null) {
			System.out.println("Sorry no song left in the queue. Use 'choose' from menu to add some. ");
		} else {
			System.out.printf("%n%n%n Open %s to hear %s by $s %n%n%n", nextSong.getVideoUrl(), nextSong.getTitle(), nextSong.getArtist());
		}
	}

}

package com.teamtreehouse.model;

import java.io.*;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.TreeMap;
import java.util.Set;

import java.io.IOException;

import java.util.Comparator;

public class SongBook {
	private List<Song> mSongs;

	public SongBook(){
		mSongs = new ArrayList<Song>();
	}

	public void addSong(Song song){
		mSongs.add(song);
	}

	public int getSongCount(){
		return mSongs.size();
	}

	private Map<String, List<Song>> byArtist() {
		Map<String, List<Song>> songsByArtist = new TreeMap<>();
		for (Song eachSong : mSongs) {
			List<Song> songsBySameArtist = songsByArtist.get(eachSong.getArtist());
			if (songsBySameArtist == null) {
				songsBySameArtist = new ArrayList<>();
				songsByArtist.put(eachSong.getArtist(), songsBySameArtist);
			}
			songsBySameArtist.add(eachSong);
		}
		return songsByArtist;
	}

	public Set<String> getArtists(){
		return byArtist().keySet();
	}

	public List<Song> getSongsByArtist(String artist) {
		List<Song> songs = byArtist().get(artist);
		songs.sort(new Comparator<Song>() {
			@Override
			public int compare (Song song1, Song song2) {
				if (song1.equals(song2)) {
					return 0;
				}
				return song1.getTitle().compareTo(song2.getTitle());  //you can also try to access mTitle here directly by changing in Song.java, the Title field to protected instead of private;
			}
		});
		return songs;
	}

	public void exportTo(String fileName){
		try(
			FileOutputStream fos = new FileOutputStream(fileName);
			PrintWriter writer = new PrintWriter(fos);
		) {
			for (Song eachSong : mSongs ) {
				writer.printf("%s|%s|%s%n", eachSong.getArtist(), eachSong.getTitle(), eachSong.getVideoUrl());
			}
		}catch(IOException ioe) {
				System.out.printf("Problem saving to file %s %n", fileName);
				ioe.printStackTrace();
			}
	}

	public void importFrom(String fileName) {
		try (
			FileInputStream fis = new FileInputStream(fileName);
			BufferedReader reader = new BufferedReader(new InputStreamReader(fis));
		) {
			String line;
			while ((line = reader.readLine()) != null ) {
				String[] args = line.split("\\|");
				addSong(new Song (args[0], args[1], args[2]));
			}
		} catch(IOException ioe) {
			System.out.printf("Problem with loading from file %s %n", fileName);
			ioe.printStackTrace();
		}
	}


// the last task of the video is to make output of KaraokeMachine.promptArtist() and KaraokeMachine.promptSongForArtist(artist)
// sorted. Looking deep into the code, we can see that promptForIndex() only display the List passed to it 
// as argument in its original order. So we have to look at how the List is originally made.
// 1) for promptArtist(), the List is made from mSongBook.getArtists(), which in turn is made in SongBook by 
// byArtist().keySet(), so to make this set ordered, we have only to make byArtist() return a TreeMap;
// 2) for promptSongForArtist(), the List of Titles is from list of songs, which in turn is made from mSongBook.getSongsByArtist(artist);
// Which returns the orignal ArrayList made by iterating through all the songs added. So the only solution 
// to make the returned list ordered is for us to manually do it.



}






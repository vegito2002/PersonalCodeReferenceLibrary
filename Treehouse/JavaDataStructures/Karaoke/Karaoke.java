import com.teamtreehouse.model.Song;
import com.teamtreehouse.model.SongBook;
import com.teamtreehouse.KaraokeMachine;

public class Karaoke {

	public static void main(String[] args){
		// Song song = new Song("Micheal Jackson", "Beat It", "www.youtube.com");
		SongBook songBook = new SongBook();
		// System.out.printf("Adding Song: %s by %s  %n", song.getTitle(), song.getArtist());
		// songBook.addSong(song);	
		// System.out.printf("There are %d songs.  %n", songBook.getSongCount());
		songBook.importFrom("songs.txt");
		KaraokeMachine machine = new KaraokeMachine(songBook);
		machine.run();
		System.out.println("Saving songbook...");
		songBook.exportTo("songs.txt");
	}
}
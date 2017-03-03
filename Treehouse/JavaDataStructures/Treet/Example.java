import java.util.Date;
import java.util.Arrays;
import java.util.Set;
import java.util.HashSet;
import java.util.TreeSet;
import java.util.Map;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.List;

import com.teamtreehouse.Treet;
import com.teamtreehouse.Treets;

public class Example {

	public static void main(String[]  args){
		// Treet treet = new Treet("Craig Dennis", "Want to be famous? Simply tweet about Java and use the hashtag #treet. I'll use your tweet in a new @treehouse course about data structures.", new Date(1421859732000l));
		// Treet secondTreet = new Treet("journeytocode","@treehouse makes learning Java soooo fun! #treet", new Date());
		// System.out.printf("This is a new Treet:   %s  %n", treet);
		// System.out.println("The words are: ");
		// for (String word: treet.getWords()) {
		// 	System.out.println(word);
		// }
		// Treet[] treets = {secondTreet, treet};
		// Arrays.sort(treets);
		// for (Treet exampleTreet : treets) {
		// 	System.out.println(exampleTreet);
		// }
		// Treets.save(treets);


		// Treet[] reloadedTreets = Treets.load();
		// for (Treet reload : reloadedTreets){
		// 	System.out.println(reload);
		// }

		Treet[] treets = Treets.load();

		// for (Treet reload : treets){
		// 	System.out.println(reload);
		// }

		System.out.printf("There are %d treets.  %n", treets.length);

		// Treet originalTreet = treets[0];
		// System.out.println("Hashtags: ");
		// for (String hashtag: originalTreet.getHashTags()) {
		// 	System.out.println(hashtag);
		// }

		Set<String> allHashTags = new HashSet<String>();
		Set<String> allMentions = new TreeSet<String>();
		for (Treet treet : treets) {
			allHashTags.addAll(treet.getHashTags());
			allMentions.addAll(treet.getMentions());
		}
		System.out.printf("All Hash Tags: %s  %n", allHashTags);
		System.out.printf("All Mentions : %s  %n", allMentions);

		Map<String, Integer> hashTagCounts = new HashMap<String, Integer>();
		for (Treet treet : treets) {
			for (String hashTag : treet.getHashTags()) {
				Integer count = hashTagCounts.get(hashTag);
				if (count == null) {
					count = 0;
				}
				count ++ ;
				hashTagCounts.put(hashTag, count);
			}
		}
		System.out.printf("All hashtag counts: %s  %n",hashTagCounts);

		Map<String,List<Treet>> treetByAuthor = new HashMap<String,List<Treet>>();
		for (Treet treet : treets) {
			List<Treet> authoredTreet = treetByAuthor.get(treet.getAuthor());
			if (authoredTreet==null) {
				authoredTreet= new ArrayList<Treet>();
				treetByAuthor.put(treet.getAuthor(),authoredTreet);
			}
			authoredTreet.add(treet);
		}
		System.out.printf("Treets by author:   %s   %n", treetByAuthor);

	}
}
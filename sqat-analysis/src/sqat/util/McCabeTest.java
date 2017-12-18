package sqat.util;

public class McCabeTest {
	public static void main(String args[]){  
		int a = 1;
		while(a < 4) {
			if(a == 1) {
				continue;
			}
			a++;
		}
		
		switch(a) {
			case 4:
				System.out.println("Excellent!"); 
	            break;
			default: 
				System.out.println("wrong input");
		}
		
		do {
			while(a < 5) {
				a *= 2;
			}
			a++;
		} while(a < 10);
		
		String[] fruits = new String[] { "Orange", "Apple", "Pear", "Strawberry" };

		for (String fruit : fruits) {
			for(int i = 0; i < a; i++) {
				System.out.println(fruit);
			}
			
		}
		
		try {
			a *= 10;
		}
		catch(Exception e) {
		}
		
		if(true && true) {
		}
		if(true || false) {
		}
	}
}


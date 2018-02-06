package intSet;

import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
//code to write to a text file when a hit statement is called IE method or line
public class InstrumentCode{
	
	FileWriter fileWriter;
	public InstrumentCode() {
		

			try {
				this.fileWriter = new FileWriter("dynamicCoverage.txt",true);
			} catch (IOException e) {
				e.printStackTrace();
			}

		
		
	}
	//hit for methods
	void hit(String className,String methodName) {
		try {
			fileWriter.write(methodName + " was hit in " + className);
		} catch (IOException e) {
			e.printStackTrace();
		}
		try {
			fileWriter.write(System.getProperty( "line.separator" ));
		} catch (IOException e1) {
			e1.printStackTrace();
		}
		try {
			fileWriter.flush();
		} catch (IOException e) {
			e.printStackTrace();
		}
		
	}
	//hit for line statements
	void hit(String className,String methodName,String lineStmt) {
		try {
			fileWriter.write(methodName + " was hit in " + className+ " with line " + lineStmt);
		} catch (IOException e) {
			e.printStackTrace();
		}
		try {
			fileWriter.write(System.getProperty( "line.separator" ));
		} catch (IOException e1) {
			e1.printStackTrace();
		}
		try {
			fileWriter.flush();
		} catch (IOException e) {
			e.printStackTrace();
		}
		
	}
	
	
	
}
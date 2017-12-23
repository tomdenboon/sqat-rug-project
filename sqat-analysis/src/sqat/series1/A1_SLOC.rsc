module sqat::series1::A1_SLOC

import IO;
import util::FileSystem;
import util::Math;
import List;
import String;
import vis::Figure;
import vis::Render;
/* 

Count Source Lines of Code (SLOC) per file:
- ignore comments
- ignore empty lines

Tips
- use locations with the project scheme: e.g. |project:///jpacman/...|
- functions to crawl directories can be found in util::FileSystem
- use the functions in IO to read source files

Answer the following questions:
- what is the biggest file in JPacman? project://jpacman-framework/src/main/java/nl/tudelft/jpacman/level/Level.java
- what is the total size of JPacman? 1887 lines of code
- is JPacman large according to SIG maintainability? No it is not
- what is the ratio between actual code and test code size? Around 76% of the project is code and 24% is test code

Sanity checks:
- write tests to ensure you are correctly skipping multi-line comments
- and to ensure that consecutive newlines are counted as one.
- compare you results to external tools sloc and/or cloc.pl

Bonus:
- write a hierarchical tree map visualization using vis::Figure and 
  vis::Render quickly see where the large files are. 
  (https://en.wikipedia.org/wiki/Treemapping) 

*/

alias SLOC = map[loc file, int sloc];

bool isNotComment(str line){
	if(startsWith(trim(line),"/*") || startsWith(trim(line),"*") || startsWith(trim(line),"//")){
		return false;
	}
	return true;
}

bool isSourceLine(str line){
	if(endsWith(trim(line),";") || endsWith(trim(line),"{") || endsWith(trim(line),":") || startsWith(trim(line),"@")){
		return true;
	}
	return false;
}

list[str] removeComments(loc file){
	list[str] listOfSourceLines = readFileLines(file);
	return [line|line<-listOfSourceLines,isNotComment(line)];
}

int sizeOfFile(list[str] fileToCount){
	return size([line|line <- fileToCount,isSourceLine(line) ]);
}

SLOC sloc(loc project) {
	SLOC result = ();
   	for(sourceFile<-files(project)){
   		if(sourceFile.extension == "java"){
   			result += (sourceFile:sizeOfFile(removeComments(sourceFile)));
   		}
   	}
	return result;
}

//Bonus:
void treeMap(SLOC slocs){
	list[Figure] boxes = [];
	for(location <- slocs.file){
		int size = slocs[location];
		//location.file
		str showText =  location.file + " " + toString(size);
		boxes += box(text(toString(size), fontColor("Red")), area(size),fillColor("Blue"));
	}
	t = treemap(boxes);
	render(t);
}

//Code for questions:
int totalSizeOfProject(loc project){
	int totalSize = 0;
	
	for(sourceFile<-files(project)){
   		if(sourceFile.extension == "java"){
   			totalSize += sizeOfFile(removeComments(sourceFile));
   		}
   	}
	return totalSize;
}

//Basic Tests:
test bool testCommentDoubleSlash()
	= isNotComment("  //   fafa") == false;
	
test bool testCommentBegin()
 	= isNotComment("  /*  agav") == false;
 	
//code will not detect source line after "*/" 
test bool testCommentEnd()
	= isNotComment(" * aga ga") == false;
	
test bool testSourceEndStatement()
	= isSourceLine("int x = 5;") == true;

test bool testSourceBeginBracket()
	= isSourceLine("for(Player p: players){") == true;
	
test bool testSourceCaseStatement()
	= isSourceLine("case 1  :") == true;

test bool testSourceAmpersand()
	= isSourceLine("  @  test ") == true;

test bool runFullCode()
	= sloc(|project://sqat-analysis/src/sqat/util/SLOCTESTS|) == (|project://sqat-analysis/src/sqat/util/SLOCTESTS/test1.java|:13);

//Extreme Cases:

//If new line starts with multiply sign but is a code line it will still be recognized as a comment
test bool caseMultiplyStartOfLine()
	= isNotComment("*5;") == false;
	
//Also if one statement is split into multiple lines it is read as one code line
test bool caseNewLineStatement()
	= sizeOfFile(["int x","= 5","+5;"]) == 1;
	
//we remove comments like these before calculating the size of the source code
test bool isolateLineDectection()
	= sizeOfFile(["//x;","/*ga*/:"]) == 2;


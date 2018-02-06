module sqat::series1::A3_CheckStyle

import lang::java::jdt::m3::AST;
import Message;
import sqat::series1::A1_SLOC;
import Set;
import IO;
import util::FileSystem;
import String;
import List;
import util::ValueUI;
import util::ResourceMarkers;
/*

Assignment: detect style violations in Java source code.
Select 3 checks out of this list:  http://checkstyle.sourceforge.net/checks.html
Compute a set[Message] (see module Message) containing 
check-style-warnings + location of  the offending source fragment. 

Plus: invent your own style violation or code smell and write a checker.

Note: since concrete matching in Rascal is "modulo Layout", you cannot
do checks of layout or comments (or, at least, this will be very hard).

JPacman has a list of enabled checks in checkstyle.xml.
If you're checking for those, introduce them first to see your implementation
finds them.

Questions
- for each violation: look at the code and describe what is going on? 
  Is it a "valid" violation, or a false positive?
  For our custom checkstyle we made a comment to declaration ratio
  the idea being that there shouldnt be too many comments describing the code
  only one real violation was found while the others were merely flavor text for the 
  npcs in the game

Tips 

- use the grammar in lang::java::\syntax::Java15 to parse source files
  (using parse(#start[CompilationUnit], aLoc), in ParseTree)
  now you can use concrete syntax matching (as in Series 0)

- alternatively: some checks can be based on the M3 ASTs.

- use the functionality defined in util::ResourceMarkers to decorate Java 
  source editors with line decorations to indicate the smell/style violation
  (e.g., addMessageMarkers(set[Message]))

  
Bonus:
- write simple "refactorings" to fix one or more classes of violations 

*/

set[Declaration] jpacmanASTs() = createAstsFromEclipseProject(|project://jpacman-framework|, true);
Declaration testStyle() = createAstFromFile(|project://CheckStyleTests/StyleTest.java|,true);
Declaration testFailStyle() = createAstFromFile(|project://CheckStyleTests/StyleFail.java|,true);


//checks for long methods
set[Message] methodLoc(loc impl,set[Message] result){
	if(20<sizeOfFile(removeComments(impl))){
		result += warning("Long method!!!",impl);
	}
	return result;
}
//finds methods and constructors and feeds them to helper function methodLoc to check for loc
set[Message] methodCountLoc(set[Declaration] decls){	
	set[Message] result = {};	
  	visit(decls){
  		case /method(_,_,_,_,Statement impl) : result += methodLoc(impl.src,result);
  		case /constructor(_,_,_,Statement impl) : result += methodLoc(impl.src,result);
  	}
  	
  	return result;
}

//creates warning if a static import is made
set[Message] importStringCheck(list[Declaration] imports,set[Message] result){

	for(x <- imports){
		if(startsWith(readFile(x.src),"import static")){

			result += warning("Static method warning!!!",x.src);
		}
	}
	return result;
}

//for each cu checks the list of imports for static imports via helper function
set[Message] staticImportCheck(set[Declaration] decls){
	
	set[Message] result = {};	

  	visit(decls){
  		case /compilationUnit(_,list[Declaration] imports,_) : 
  			result += importStringCheck(imports,result);
  		case /compilationUnit(list[Declaration] imports,_) : 
  			result += importStringCheck(imports,result);
  	}

  	return result;
}

//tallies up return statements in a method
int getReturn(Statement method){
	int result = 0;
	visit(method){
        case \return(_) : result += 1; 
        case \return() : result += 1;
	}	
	return result;
}
//Checks if there are too many return statements in a method
set[Message] returnStatementCountCheck(set[Declaration] decls){
	set[Message] result = {};
	
	visit(decls){
		case /method(_,_,_,_,Statement impl) :
			if(getReturn(impl) > 3){
					result += warning("TOO many returns!!!",impl.src);
		}
	}
	
	return result;
}

//tallies up declarations in a class
int getNumberOfDeclaration(list[Declaration] body, loc classLocation){
	//start at 1 because we count the starting method we go into this function with
	int result = 1;
	visit(body){
		case Declaration m:method(_,_,_,_,_) : result += 1;
		case Declaration m:method(_,_,_,_) : result += 1;
		case Declaration c:class(_,_,_,_) : result += 1;
		case Declaration c:constructor(_,_,_,_) : result += 1;
		case Declaration f:field(_,_) : result += 1;//count field as well because explanation might be needed for it
	}
	
	return result;

}

int getNumberOfComments(loc class){
	return size([x|x<-readFileLines(class),startsWith(trim(x),"//") || (startsWith(trim(x),"*") && size(trim(x)) > 2)]);

}

//checks whether there are too many comments in a class compared to the amount of declarations
set[Message] commentRatioCheck(set[Declaration] decls){
	set[Message] result = {};
	
	visit(decls){
		case theClass:class(_,_,_,list[Declaration] body) :
			if((getNumberOfComments(theClass.src)/getNumberOfDeclaration(body,theClass.src)) > 4){
				result += warning("Comment to declaration ratio too high!!!",theClass.src);
			}
	}
	return result;
}

set[Message] checkStyle() {
  	set[Message] result = {};
  	result += methodCountLoc(jpacmanASTs());
  	result += staticImportCheck(jpacmanASTs());
  	result += returnStatementCountCheck(jpacmanASTs());
  	result += commentRatioCheck(jpacmanASTs());
  	
  	return result;
}

void messageMarker(){

	addMessageMarkers(checkStyle());
}

//helper test function to let file be used in functions
set[Declaration] testHelper(Declaration decl){
	set[Declaration] help = {};
	help += decl;
	return help;
}
//pass tests:
test bool staticImportCheckTest()
	= size(staticImportCheck(testHelper(testStyle()))) == 1;
	
test bool returnStatementCountCheckTest()
	= size(returnStatementCountCheck(testHelper(testStyle()))) == 1;
	
test bool commentRatioCheckTest()
	= size(commentRatioCheck(testHelper(testStyle()))) == 1;
	
test bool methodCountLocTest()
	= size(methodCountLoc(testHelper(testStyle()))) == 1;
//fail tests:
test bool staticImportCheckTest()
	= size(staticImportCheck(testHelper(testFailStyle()))) == 0;
	
test bool returnStatementCountCheckTest()
	= size(returnStatementCountCheck(testHelper(testFailStyle()))) == 0;
	
test bool commentRatioCheckTest()
	= size(commentRatioCheck(testHelper(testFailStyle()))) == 0;
	
test bool methodCountLocTest()
	= size(methodCountLoc(testHelper(testFailStyle()))) == 0;


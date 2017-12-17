module sqat::series1::A3_CheckStyle

import lang::java::\syntax::Java15;
import lang::java::jdt::m3::AST;
import Message;
import sqat::series1::A1_SLOC;
import Set;
import IO;
import util::FileSystem;
import ParseTree;
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

set[Message] methodLoc(loc impl,set[Message] result){
	if(20<sizeOfFile(removeComments(impl))){
		result += warning("Long method!!!",impl);
	}
	return result;
}

set[Message] methodCount(){	
	set[Message] result = {};	
	for(x<-jpacmanASTs()){
  		visit(x){
  			case /method(_,_,_,_,Statement impl) : result += methodLoc(impl.src,result);
  			case /constructor(_,_,_,Statement impl) : result += methodLoc(impl.src,result);
  		}
  	}
  	return result;
}

set[Message] staticImportCheck(start[CompilationUnit] cu){
	set[Message] result = {};
	
	visit(cu){
		case theMethod:(ImportDec)`"import""static"<TypeName n><Id x>`:
			result += warning("Static import!!!",theImport@\loc);
	
	
	}
	return result;
}

set[Message] checkStyle(loc project) {
  	set[Message] result = {};
  	result += methodCount();
  
 	 for (loc l <- files(project), l.extension == "java") {
    	result += staticImportCheck(parse(#start[CompilationUnit], l, allowAmbiguity=true));
 	 }
  
  	return result;
}

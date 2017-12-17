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

  	visit(jpacmanASTs()){
  		case /method(_,_,_,_,Statement impl) : result += methodLoc(impl.src,result);
  		case /constructor(_,_,_,Statement impl) : result += methodLoc(impl.src,result);
  	}
  	
  	return result;
}

set[Message] importStringCheck(list[Declaration] imports,set[Message] result){

	for(x <- imports){
		if(startsWith(readFile(x.src),"import static")){
		
			result += warning("Static method!!!",x.src);
		}
	}
	return result;
}

set[Message] staticImportCheck(){
	
	set[Message] result = {};	

  	visit(jpacmanASTs()){
  		case /compilationUnit(_,list[Declaration] imports,_) : result += importStringCheck(imports,result);
  	}

  	return result;
}


int getReturn(Statement method){
	int result = 0;
	visit(method){
        case \return(_) : result += 1; 
        case \return() : result += 1;
	}	
	return result;
}

set[Message] returnStatementCountCheck(){
	set[Message] result = {};
	
	
	visit(jpacmanASTs()){
		case /method(_,_,_,_,Statement impl) :
			if(getReturn(impl) > 3){
					result += warning("TOO MANY RETURNS!!!",impl.src);
		}
	}
	
	return result;
}

int getDeclaration(list[Declaration] body,loc class){
	int result = 1;
	visit(body){
		case method(_,_,_,_,Statement impl) : result +=1;
		case field(_,_): result +=1;
		case constructor(_,_,_,_) : result +=1;
	}
	return result;

}

int getComments(loc class){
	return size([x|x<-readFileLines(class),startsWith(trim(x),"//") || (startsWith(trim(x),"*") && size(trim(x)) > 2)]);

}

set[Message] getCommentRatio(){
	set[Message] result = {};
	
	visit(jpacmanASTs()){
		case theClass:class(_,_,_,list[Declaration] body) :
			if((getComments(theClass.src)/getDeclaration(theClass.body,theClass.src)) >4){
				result += warning("Comment to declaration ratio too high!!!",theClass.src);
			}
	}
	
	return result;
}

set[Message] checkStyle(loc project) {
  	set[Message] result = {};
  	//result += methodCount();
  	//result += staticImportCheck();
  	//result += returnStatementCountCheck();
  	//result += getCommentRatio();
  	
  	return result;
}

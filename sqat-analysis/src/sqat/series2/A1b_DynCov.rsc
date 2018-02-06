module sqat::series2::A1b_DynCov

import lang::java::jdt::m3::Core;
import util::FileSystem;
import IO;
import util::ValueUI;
import String;
import util::Math;
import Set;
/*

Assignment: instrument (non-test) code to collect dynamic coverage data.

- Write a little Java class that contains an API for collecting coverage information
  and writing it to a file. NB: if you write out CSV, it will be easy to read into Rascal
  for further processing and analysis (see here: lang::csv::IO)

- Write two transformations:
  1. to obtain method coverage statistics
     (at the beginning of each method M in class C, insert statement `hit("C", "M")`
  2. to obtain line-coverage statistics
     (insert hit("C", "M", "<line>"); after every statement.)

The idea is that running the test-suite on the transformed program will produce dynamic
coverage information through the insert calls to your little API.

Questions
- use a third-party coverage tool (e.g. Clover) to compare your results to (explain differences)
- which methods have full line coverage?
- which methods are not covered at all, and why does it matter (if so)?
- what are the drawbacks of source-based instrumentation?

Tips:
- create a shadow JPacman project (e.g. jpacman-instrumented) to write out the transformed source files.
  Then run the tests there. You can update source locations l = |project://jpacman/....| to point to the 
  same location in a different project by updating its authority: l.authority = "jpacman-instrumented"; 

- to insert statements in a list, you have to match the list itself in its context, e.g. in visit:
     case (Block)`{<BlockStm* stms>}` => (Block)`{<BlockStm insertedStm> <BlockStm* stms>}` 
  
- or (easier) use the helper function provide below to insert stuff after every
  statement in a statement list.

- to parse ordinary values (int/str etc.) into Java15 syntax trees, use the notation
   [NT]"...", where NT represents the desired non-terminal (e.g. Expr, IntLiteral etc.).  

*/

M3 m() = createM3FromEclipseProject(|project://intSetMod|);

//gets a set of all method calls from text report
set[str] getCallsFromText(loc textFile){

	list[str] methodHits = readFileLines(textFile);
	set[str] methodCalls= {};
	
	for(hit <- methodHits){
	
		methodCalls += hit;
		
	}
	return methodCalls;

}
//gets all main methods from M3 model
set[loc] getMethodsFromM3(str filePath){
	rel[loc name, loc src] decls = m().declarations;
	set[loc] allMethods = {};
	
	for(decl <- decls){
		
		if(isMethod(decl.name) && contains(decl.src.path,filePath)){
			
			allMethods += decl.name;
		
		}
	}
	return allMethods;
}


int methodCoverage(loc textFile,str filePath) {

	set[loc] allMethods = getMethodsFromM3(filePath);
	set[str] methodCalls = getCallsFromText(textFile);
	set[loc] methodsCovered = {};
	
	int countMatches = 0;
	//each call in the text file is checked against all the methods from the M3 model
	for(methd <- allMethods){
	
		for(call <- methodCalls){
		
			if(contains(call,methd.file)){
			
				countMatches +=1;
				methodsCovered+=methd;
				
			}
		}
	}
	
	text(allMethods - methodsCovered);
	return percent(countMatches,size(allMethods));
}



void lineCoverage(loc project) {
  // to be done
}




test bool CheckTextCalls()
	= getCallsFromText(|project://intSet/testTextForRascal.txt|) == {"A was hit in B"};
	
test bool CheckFakeTextWithM3()
	= methodCoverage(|project://intSet/testTextForRascal.txt|,"src/main") == 0;
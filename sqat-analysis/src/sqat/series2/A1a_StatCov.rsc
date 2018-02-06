module sqat::series2::A1a_StatCov

import lang::java::jdt::m3::Core;
import util::ValueUI;
import Relation;
import String;
import IO;
import Set;
import util::Math;
import List;
/*

Implement static code coverage metrics by Alves & Visser 
(https://www.sig.eu/en/about-sig/publications/static-estimation-test-coverage)


The relevant base data types provided by M3 can be found here:

- module analysis::m3::Core:

rel[loc name, loc src]        M3@declarations;            // maps declarations to where they are declared. contains any kind of data or type or code declaration (classes, fields, methods, variables, etc. etc.)
rel[loc name, TypeSymbol typ] M3@types;                   // assigns types to declared source code artifacts
rel[loc src, loc name]        M3@uses;                    // maps source locations of usages to the respective declarations
rel[loc from, loc to]         M3@containment;             // what is logically contained in what else (not necessarily physically, but usually also)
list[Message]                 M3@messages;                // error messages and warnings produced while constructing a single m3 model
rel[str simpleName, loc qualifiedName]  M3@names;         // convenience mapping from logical names to end-user readable (GUI) names, and vice versa
rel[loc definition, loc comments]       M3@documentation; // comments and javadoc attached to declared things
rel[loc definition, Modifier modifier] M3@modifiers;     // modifiers associated with declared things

- module  lang::java::m3::Core:

rel[loc from, loc to] M3@extends;            // classes extending classes and interfaces extending interfaces
rel[loc from, loc to] M3@implements;         // classes implementing interfaces
rel[loc from, loc to] M3@methodInvocation;   // methods calling each other (including constructors)
rel[loc from, loc to] M3@fieldAccess;        // code using data (like fields)
rel[loc from, loc to] M3@typeDependency;     // using a type literal in some code (types of variables, annotations)
rel[loc from, loc to] M3@methodOverrides;    // which method override which other methods
rel[loc declaration, loc annotation] M3@annotations;

Tips
- encode (labeled) graphs as ternary relations: rel[Node,Label,Node]
- define a data type for node types and edge types (labels) 
- use the solve statement to implement your own (custom) transitive closure for reachability.

Questions:
- what methods are not covered at all?
 there are exactly 90 methods not covered, can be shown by invoking getMethodsNotTested
- how do your results compare to the jpacman results in the paper? Has jpacman improved?
	Our results are worse, so either our method of finding coverage is not as accurate or
	the project has became worse as far as test quality goes
- use a third-party coverage tool (e.g. Clover) to compare your results to (explain differences)


*/


//M3 m() = createM3FromEclipseProject(|project://jpacman-framework|);

M3 m() = createM3FromEclipseProject(|project://intSet|);
//use this M3 for testing only,comment out other


//gets all methods and constructors
rel[loc name, loc src] getMethods(){
	
	rel[loc name, loc src] allMethods = {};
	
	for(decl <- m().declarations){
		if(isMethod(decl.name)){
		
		allMethods += decl;
		
		}
	}
	return allMethods;
}

//gets all method invocations as well as the transitive ones
rel[loc name, loc src] getCallsTransitively(){

	rel[loc from, loc to] allMethodCalls = m().methodInvocation;
	
	solve(allMethodCalls){
		allMethodCalls = allMethodCalls + (allMethodCalls o allMethodCalls);
	
	
	}
	return allMethodCalls;
}

//extracts from test methods from the rest
set[loc] getTestMethods(){
	set[loc] testMethods = {};
	
	rel[loc name, loc src] allMethods = getMethods();
	
	for(methd <- allMethods){
		if(startsWith(methd.src.path,"/src/test")){
			testMethods += methd.name;
		}
	}
	return testMethods;
}

//extracts the actual methods of the project from the test methods
set[loc] getMainMethods(){
	set[loc] testMethods = {};
	
	rel[loc name, loc src] allMethods = getMethods();
	
	for(methd <- allMethods){
		if(startsWith(methd.src.path,"/src/main")){
			testMethods += methd.name;
		}
	}
	return testMethods;
}
//gets all the method invocations just for the test methods
set[loc] getMethodInvocFromTests(){
	set[loc] testInvocs = {};
	
	set[loc] testMethods = getTestMethods();
	rel[loc from, loc to] allCalls = getCallsTransitively();
	
	for(methd <- testMethods){
	
		testInvocs += allCalls[methd];
	}
	return testInvocs;
	
}
//removes methods that are called from other sources such as java libraries and such
//it also removes test methods since test methods can call other test methods
//finally we remove any method with anonymous at the end, it seems to appear with GUI stuff like buttons
//since those methods are already covered no reason to keep a version of them that only appears in the invocations
set[loc] removeMethodsNotInProject(str pathName){
	set[loc] allInvocs = getMethodInvocFromTests();

	set[loc] onlyLocalMethods = {};
	
	for(methd <- allInvocs){
		if(startsWith(methd.path,pathName) && methd notin getTestMethods() && !(contains(methd.path,"anonymous"))){
			onlyLocalMethods += methd;
		}
	}
	return onlyLocalMethods;
}

int getCodeCoverage(str pathName){
	
	int codeCoverage = percent(size(removeMethodsNotInProject(pathName)),size(getMainMethods()));
	return codeCoverage;

}

int getMethodsNotTested(str pathName){
	set[loc] unTested = getMainMethods() - removeMethodsNotInProject(pathName);
	text(unTested);
	return size(unTested);
	
}

test bool codeCoverageTest()
	= getCodeCoverage("/intSet") == 100;
	
test bool getMethodsNotTestedTest()
	= getMethodsNotTested("/intSet") == 0;

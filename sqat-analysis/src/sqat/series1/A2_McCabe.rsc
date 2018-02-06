module sqat::series1::A2_McCabe

import lang::java::jdt::m3::AST;
import sqat::series1::A1_SLOC;
import IO;
import Relation;
import Set;
import util::Math;
import vis::Figure;
import vis::Render;
import util::ValueUI;
import analysis::statistics::Correlation;
import String;
import List;
/*

Construct a distribution of method cylcomatic complexity. 
(that is: a map[int, int] where the key is the McCabe complexity, and the value the frequency it occurs)


Questions:
- which method has the highest complexity (use the @src annotation to get a method's location)
|project://jpacman-framework/src/main/java/nl/tudelft/jpacman/npc/ghost/Inky.java|(3664,988,<96,29>,<131,17>) cc= 8
- how does pacman fare w.r.t. the SIG maintainability McCabe thresholds?
Seeing as the most of the methods have a complexity of 1 and only couple at 4-5 the pacman project fares well on the SIG table.
- is code size correlated with McCabe in this case (use functions in analysis::statistics::Correlation to find out)? 
  (Background: Davy Landman, Alexander Serebrenik, Eric Bouwers and Jurgen J. Vinju. Empirical analysis 
  of the relationship between CC and SLOC in a large corpus of Java methods 
  and C functions Journal of Software: Evolution and Process. 2016. 
  http://homepages.cwi.nl/~jurgenv/papers/JSEP-2015.pdf)
After using the correlation function comparing the lines of code and the cc of a method. We get a value of 0.7008536178241318
which indicates that in jpacman they are correlated
- what if you separate out the test sources?
no correlation for tests
.795 for just the main code

Tips: 
- the AST data type can be found in module lang::java::m3::AST
- use visit to quickly find methods in Declaration ASTs
- compute McCabe by matching on AST nodes

Sanity checks
- write tests to check your implementation of McCabe

Bonus
- write visualization using vis::Figure and vis::Render to render a histogram.

*/

set[Declaration] jpacmanASTs() = createAstsFromEclipseProject(|project://jpacman-framework|, true);
Declaration testASTs() = createAstFromFile(|project://McCabeTests/McCabeTest.java|, true);


alias CC = rel[loc method, int cc];
//adds up CC for a given method's statements
int methodCount(Statement impl) {
    int result = 1;
    visit (impl) {
    	case \continue() : result += 1;
    	case \continue(_) : result += 1;
        case \if(_,_) : result += 1;
        case \if(_,_,_) : result += 1;
        case \case(_) : result += 1;
        case \defaultCase() : result += 1;
        case \do(_,_) : result += 1;
        case \while(_,_) : result += 1;
        case \break() : result += 1;
        case \for(_,_,_) : result += 1;
        case \for(_,_,_,_) : result += 1;
        case \foreach(_,_,_) : result += 1;
        case \catch(_,_): result += 1;
        case \infix(_,"&&",_) : result += 1;
        case \infix(_,"||",_) : result += 1;
        case \infix(_,"?",_) : result += 1;
        case \infix(_,":",_) : result += 1;
    }
    return result;
}

CC cc(set[Declaration] decls) {
	CC result = {};
	//computes CC for each method and constructor with a body
  	visit(decls){
  		case /method(_,_,_,_,Statement impl) : result += (<impl.src,methodCount(impl)>);
  		case /constructor(_,_,_,Statement impl) : result += (<impl.src,methodCount(impl)>);
  	}
	return result;
}
//specify what folder path to check
CC ccSplit(set[Declaration] decls,str folderPath) {
	CC result = {};
	//computes CC for each method and constructor with a body
  	visit(decls){
  		case /method(_,_,_,_,Statement impl) :
  			//checks to see if the method is contained in the folder path specified
  			if(contains(impl.src.path,folderPath)){
  			 	result += (<impl.src,methodCount(impl)>);
  			 }
  		case /constructor(_,_,_,Statement impl) :
  		
  			if(contains(impl.src.path,folderPath)){
  			 	result += (<impl.src,methodCount(impl)>);
  			 }
  	}
	return result;
}

alias CCDist = map[int cc, int freq];

// getting the histogram in map form.
CCDist ccDist(CC cc) {
	CCDist finalHisto = ();
	for(int init <- cc.cc){
		finalHisto += (init:0);
	}
	
	set[loc] ccLocs = cc.method;
 	for(loc c <- ccLocs){
 		
 		set[int] ccInts = cc[c];
 		for(int i <- ccInts){
 			int frequency = finalHisto[i] + 1;
 			finalHisto += (i:frequency);
 		}
 	}
 	
 	return(finalHisto);
}

//correlation question
num correlation(CC cc){
	SLOC size = ();
	lrel[num cycloComp,num lines] linesAndCC = [];
	set[loc] ccLocs = cc.method;
	
	for(methodLoc <- ccLocs){
		size += sloc(methodLoc);
		linesAndCC += (<getOneFrom(cc[methodLoc]),size[methodLoc]>);
	}

	return PearsonsCorrelation(linesAndCC);
}
//helper function for test need turn decl to a set of decl in order to run cc
CCDist testHelper(){
	set[Declaration] helper = {};
	helper += testASTs();
	return ccDist(cc(helper));
	
}
// rendering the histogram.
void histogram(CCDist histo){
	list[Figure] allFigs = [];

	num max = max(histo.freq);
	
	for(int c <- sort([ c0 | c0 <- histo.cc])){
 		int freq = histo[c];
 		num sized = freq/max; 
 		allFigs += box(text(toString(c), fontColor("Red")), vshrink(sized), fillColor("Blue"));
 	}
	render(hcat(allFigs, std(bottom()), gap(5)));
}

test bool checkCase()
	= testHelper()== (15:1);



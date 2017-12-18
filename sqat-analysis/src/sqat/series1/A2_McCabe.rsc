module sqat::series1::A2_McCabe

import lang::java::jdt::m3::AST;
import IO;
import Relation;
import Set;
import util::Math;
import vis::Figure;
import vis::Render;
import util::ValueUI;
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
  
- what if you separate out the test sources?

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
set[Declaration] testASTs() = createAstsFromEclipseProject(|project://sqat-analysis/src/sqat/util/McCabeTest.java|, true);

alias CC = rel[int cc, loc method];

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

  	visit(decls){
  		case /method(_,_,_,_,Statement impl) : result += (<methodCount(impl),impl.src>);
  		case /constructor(_,_,_,Statement impl) : result += (<methodCount(impl),impl.src>);
  	}
 
	return result;
}

void check(){
	text(jpacmanASTs());
}


alias CCDist = map[int cc, int freq];

// getting the histogram in map form.
CCDist ccDist(CC cc) {
	CCDist finalHisto = ();
	set[int] ccInts = cc.cc;
 	for(int c <- sort(ccInts)){
 		print(c);
 		int freq = size(cc[c]);
		finalHisto += (c:freq);
 	}
 	return(finalHisto);
}

// rendering the histogram.
void histogram(CCDist histo){
	list[Figure] allFigs = [];

	num max = max(histo.freq);
	
	for(int c <- histo.cc){
 		int freq = histo[c];
 		num sized = freq/max; 
 		allFigs += box(text(toString(c), fontColor("Red")), vshrink(sized), fillColor("Blue"));
 	}
	render(hcat(allFigs, std(bottom()), gap(5)));
}

test bool checkCase()
	= cc(testASTs())== ({<15,|project://sqat-analysis/src/sqat/util/McCabeTest.java|(88,639,<4,39>,<47,2>)>});



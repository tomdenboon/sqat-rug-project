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
- what is the biggest file in JPacman?
- what is the total size of JPacman?
- is JPacman large according to SIG maintainability?
- what is the ratio between actual code and test code size?

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

list[str] removeComments(loc file){
	list[str] noComments = [];
  	for(s <- readFileLines(file)){
    	if(!(/((\s|\/*)(\/\*|\s\*)|[^\w,\;]\s\/*\/|(^\/))/ := s)) {
     		noComments += s;
     	}
	}
	return noComments;
}

SLOC sloc(loc project) {
	SLOC result = ();
	int sizeOfFile = 0;
   	for(sourceFile<-files(project)){
   		if(sourceFile.extension == "java"){
   			list[str] noComments = removeComments(sourceFile);
   			sizeOfFile = size([x|x <- noComments,endsWith(x,";") || endsWith(x,"{") || endsWith(x,":") || startsWith(x,"@") ]);
   			result += (sourceFile:sizeOfFile);
   		}
   	}
	return result;
}

void treeMap(SLOC slocs){
	list[Figure] boxes = [];
	for(location <- slocs.file){
		int size = slocs[location];
		//location.file
		str showText = location.file + " " + toString(size);
		boxes += box(text(showText, fontColor("Red")), area(size),fillColor("Blue"));
	}
	t = treemap(boxes);
	render(t);
}

test bool newLines(){
	
}
module sqat::series1::A1_SLOC

import IO;
import util::FileSystem;
import List;
import String;
import reader::Reader;

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


	
SLOC sloc(loc project) {
  SLOC result = ();
  int linesOfCode = 0, countMain = 0, countTest = 0;
  for(thisFile <- files(project)){
    // Checks if the file is not a resource file
  	set[loc] javaFiles = files(|project://sqat-rug-project/jpacman/src/main/java|);
    set[loc] testFiles = files(|project://sqat-rug-project/jpacman/src/test/java|);
    bool flagMain = false, flagTest = false;
    
  	for(loc this <- javaFiles){
  	  if(this == thisFile){
        flagMain = true;
        break;
      }
    }
    
  	for(loc this <- testFiles){
  	  if(this == thisFile){
  	    flagTest = true;
  	    break;
  	  }
  	}
  	
  	if(flagMain || flagTest){
      list[str] allLinesInFile = [x|x <- readFileLines(thisFile),trim(x) != "",trim(x)[0] != "/",
                                   trim(x)[0] != "*"];
      allLinesInFile = [x|x <- allLinesInFile,x[size(x)-1] == "{" || x[size(x)-1] == "}" || 
                         x[size(x)-1] == ";" || x[size(x)-1] == ":"];
                         
      linesOfCode = size(allLinesInFile);
      result += (thisFile:linesOfCode);
      if(flagMain) countMain += linesOfCode;
      else countTest += linesOfCode;
    }
    
  }
  printlnExp("Actual Code: ", countMain);
  printlnExp("Test code: ", countTest);
  printlnExp("Total code: ", countMain + countTest);
  return result;
}
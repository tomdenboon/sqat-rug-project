module sqat::series2::A2_CheckArch

import sqat::series2::Dicto;
import lang::java::jdt::m3::Core;
import Message;
import ParseTree;
import String;
import IO;
import util::ValueUI;

/*

This assignment has two parts:
- write a dicto file (see example.dicto for an example)
  containing 3 or more architectural rules for Pacman
  
- write an evaluator for the Dicto language that checks for
  violations of these rules. 

Part 1  

An example is: ensure that the game logic component does not 
depend on the GUI subsystem. Another example could relate to
the proper use of factories.   

Make sure that at least one of them is violated (perhaps by
first introducing the violation).

Explain why your rule encodes "good" design.
  
Part 2:  
 
Complete the body of this function to check a Dicto rule
against the information on the M3 model (which will come
from the pacman project). 

A simple way to get started is to pattern match on variants
of the rules, like so:

switch (rule) {
  case (Rule)`<Entity e1> cannot depend <Entity e2>`: ...
  case (Rule)`<Entity e1> must invoke <Entity e2>`: ...
  ....
}

Implement each specific check for each case in a separate function.
If there's a violation, produce an error in the `msgs` set.  
Later on you can factor out commonality between rules if needed.

The messages you produce will be automatically marked in the Java
file editors of Eclipse (see Plugin.rsc for how it works).

Tip:
- for info on M3 see series2/A1a_StatCov.rsc.

Questions
- how would you test your evaluator of Dicto rules? (sketch a design)
- come up with 3 rule types that are not currently supported by this version
  of Dicto (and explain why you'd need them). 
*/
M3 m() = createM3FromEclipseProject(|project://jpacman-framework|);

set[Message] eval(start[Dicto] dicto, M3 m3) = eval(dicto.top, m3);
set[Message] eval((Dicto)`<Rule* rules>`, M3 m3) 
  = ( {} | it + eval(r, m3) | r <- rules );
  
set[Message] eval(Rule rule, M3 m3) {
  set[Message] msgs = {};
  switch(rule){
  	case (Rule)`<Entity e1> cannot instantiate <Entity e2>`: msgs = checkInstantiate(e1,e2,msgs);
  	case (Rule)`<Entity e1> must instantiate <Entity e2>`: msgs = checkInstantiate(e1,e2,msgs);
  	case (Rule)`<Entity e1> cannot import <Entity e2>`: msgs = checkImport(e1,e2,msgs);
  	case (Rule)`<Entity e1> cannot depend <Entity e2>`: msgs = checkDepend(e1,e2,msgs);
  }
  
  return msgs;
}

void test1(){
  Dicto d = parse(#Dicto,|project://sqat-analysis/src/sqat/series2/example.dicto|,allowAmbiguity= true);
  eval(d,m());

}


set[Message] checkImport(Entity e1,Entity e2,set[Message] msgs){

  return msgs;
}
set[Message] checkDepend(Entity e1,Entity e2,set[Message] msgs){

  
  return msgs;
}
set[Message] checkInstantiate(Entity e1,Entity e2,set[Message] msgs){

  rel[loc from, loc to] allMethods = m().methodInvocation;
  solve(allMethods) allMethods = allMethods + (allMethods o allMethods);
  
  rel[str from, str to] fromTo = {};
  
  for(meth<-allMethods){
    str fromMethod = (meth.from).file;
    str toMethod = (meth.to).file;
	
	
	if(contains(fromMethod,"makeGame")) fromTo += (<fromMethod, toMethod>);
  
  }
  text(fromTo);

  return msgs;
}
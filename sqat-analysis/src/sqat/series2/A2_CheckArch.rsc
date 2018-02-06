module sqat::series2::A2_CheckArch

import sqat::series2::Dicto;
import lang::java::jdt::m3::Core;
import Message;
import Relation;
import ParseTree;
import IO;
import String;
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
    case (Rule)`<Entity e1> must import <Entity e2>`: msgs = mustImport(e1,e2,msgs); //works
    case (Rule)`<Entity e1> cannot depend <Entity e2>`: msgs = cannotDependOn(e1,e2,msgs); //works
    case (Rule)`<Entity e1> must instantiate <Entity e2>`: msgs = mustInstantiate(e1,e2,msgs); //pretty sure it works
    case (Rule)`<Entity e1> cannot invoke <Entity e2>`: msgs = cannotInvoke(e1,e2,msgs); //works
    case (Rule)`<Entity e1> must inherit <Entity e2>`: msgs = mustInherit(e1,e2,msgs); //works
  }
  
  return msgs;
}

void test1(){
  Dicto d = parse(#Dicto,|project://sqat-analysis/src/sqat/series2/example.dicto|,allowAmbiguity= true);
  set[Message] msgs = eval(d,m());
  text(msgs);
}

// retrieves an entity as location from the m3 model
loc findsEntityInM3(str entityStr){

  rel[loc name, loc src] decl = m().declarations;
  
  for(d<-decl){
    str name = replaceAll((d.name).path[1..], "nl/tudelft/jpacman/", "");
    str src = replaceAll((d.src).path[1..], "nl/tudelft/jpacman/", "");
    
    if(name == entityStr){
      return d.name;
    }
    
    if(src == entityStr){
      return d.src;
    }
  }
  
  for(d<-decl){
    str name = replaceAll((d.name).path[1..], "nl/tudelft/jpacman/", "") + "(";
    str src = replaceAll((d.src).path[1..], "nl/tudelft/jpacman/", "") + "(";
    
    if(startsWith(name, entityStr) && isMethod(d.name)){
      return d.name;
    }
    
    if(startsWith(src, entityStr) && isMethod(d.src)){
      return d.src;
    }
  }
}

// marks for violations on package/class/method must instantiate class
set[Message] mustInstantiate(Entity e1, Entity e2, set[Message] msgs){

  loc entity1 = findsEntityInM3(replaceAll(replaceAll("<e1>", ".", "/"),"::","/"));
  loc entity2 = findsEntityInM3(replaceAll(replaceAll("<e2>", ".", "/"),"::","/"));
  
  print(entity1);
  print(" ");
  println(entity2);
  
  str warn = "<e1>" + " must instantiate " + "<e2>";
  
  rel[loc from, loc to] instantiates = m().methodInvocation*;
  set[loc method] methods = {};
  
  // retrieve all the methods and constructors
  if(isPackage(entity1)){
    for(javaUnit<-m().containment[entity1]){
      for(class<-m().containment[javaUnit]){
        methods += (m().containment[class]);
      }
    }
  }
  else if(isClass(entity1)){
    methods += m().containment[entity1];
  } 
  else if(isMethod(entity1)){
    methods += entity1;
  }
  
  
  set[loc con] constructorsEntity2 = {};
  // retrieve the constructors of must instantiate class
  for(constr <- m().containment[entity2]){
    if(isConstructor(constr)){
      constructorsEntity2 += constr;
    }
  }
  
  // checks if one of methods inside the package, class calls the constructor, if this is not the case marks the violation
  bool instantiated = false;
  for(meth <- methods){
    set[loc to] instantiation = instantiates[meth];
    for(i <- instantiation){
      for(constructor <- constructorsEntity2){
        if(i == constructor){ 
          instantiated = true;
          break;
        }
      }
    }
  }
  if(!instantiated){ msgs += warning(warn, entity1); }
  
  return msgs;
}

// marks the violations on "package/class/method cannot invoke method"
set[Message] cannotInvoke(Entity e1, Entity e2, set[Message] msgs){

  loc entity1 = findsEntityInM3(replaceAll(replaceAll("<e1>", ".", "/"),"::","/"));
  loc entity2 = findsEntityInM3(replaceAll(replaceAll("<e2>", ".", "/"),"::","/"));
  
  print(entity1);
  print(" ");
  println(entity2);
  
  str warn = "<e1>" + " cannot invoke " + "<e2>";
  
  rel[loc from, loc to] invokes = m().methodInvocation*;
  set[loc method] methods = {};
  
  // get all the methods from the classes
  if(isPackage(entity1)){
    for(javaUnit<-m().containment[entity1]){
      for(class<-m().containment[javaUnit]){
        methods += (m().containment[class]);
      }
    }
  }
  else if(isClass(entity1)){
    methods = m().containment[entity1];
  } 
  else if(isMethod(entity1)){
    methods += entity1;
  }
  
  // now if one of these methods invokes the cannot invoke method mark them
  for(m <- methods){
    set[loc to] invocation = invokes[m];
    for(i <- invocation){
      if(i == entity2){ 
        msgs += warning(warn, m); 
      }
    }
  }
  
  return msgs;
}

// checks for violations on package/class must inherit class
set[Message] mustInherit(Entity e1, Entity e2, set[Message] msgs){

  str warn = "<e1>" + " must inherit " + "<e2>";
  
  bool inherits = false;
  loc entity1 = findsEntityInM3(replaceAll(replaceAll("<e1>", ".", "/"),"::","/"));
  loc entity2 = findsEntityInM3(replaceAll(replaceAll("<e2>", ".", "/"),"::","/"));
  
  print(entity1);
  print(" ");
  println(entity2);
  
  
  rel[loc from, loc to] extends = m().extends*;
  set[loc] class = {};
  
  // retrieve all classes that must inherit the class
  if(isPackage(entity1)){
    for(javaUnit<-m().containment[entity1]){
      class += (m().containment[javaUnit]);
    }
  }
  else if(isClass(entity1)){
    class += entity1;
  }
 
  // check for the classes to extend the correct class, if not mark them
  for(c <- class){
    inherits = false;
    set[loc] extension = extends[c];
    for(e <- extension){
      if(e == entity2){
        inherits = true;
        break;
      }
    }
    if(!inherits){msgs += warning(warn, c);}
  }
  
  return msgs;
}

// checks for violations on "package/class cannot depend package/class"
set[Message] cannotDependOn(Entity e1, Entity e2, set[Message] msgs){
  loc entity1 = findsEntityInM3(replaceAll(replaceAll("<e1>", ".", "/"),"::","/"));
  loc entity2 = findsEntityInM3(replaceAll(replaceAll("<e2>", ".", "/"),"::","/"));
  
  str warn = "<e1>" + " cannot depend " + "<e2>";
  
  print(entity1);
  print(" ");
  println(entity2);
  
  rel[loc from, loc to] dependsOn = m().typeDependency*;
  set[loc method] methods = {};
  rel[loc from, loc to] contains = m().containment;
  
  // get all methods from the package of entity1
  if(isPackage(entity1)){
    for(jUnit<-contains[entity1]){
      for(class<-contains[jUnit]){
        for(method<-contains[class]){
          methods += method;
        }
      }
    }
  }
  else if(isClass(entity1)){
    for(method<-contains[entity1]){
      methods += method;
    }
  }
  else if(isMethod(entity1)){
    methods += entity1;
  }
  
  // Check if any of the methods of entity1 depends on entity2 and mark them
  for(m <- methods){
    set[loc dependency] dependencys = dependsOn[m];
    for(d <- dependencys){
      if(entity2 == d){
        msgs += warning(warn, m);
      }
    }
  }
  return msgs;
}

// checks for violations on "package/class must import package/class"
set[Message] mustImport(Entity e1, Entity e2, set[Message] msgs){
  
  loc entity1 = findsEntityInM3(replaceAll(replaceAll("<e1>", ".", "/"),"::","/"));
  loc entity2 = findsEntityInM3(replaceAll(replaceAll("<e2>", ".", "/"),"::","/"));
  
  str warn = "<e1>" + " must import " + "<e2>";
  
  print(entity1);
  print(" ");
  println(entity2);
  
  rel[loc from, loc to] importStatement = m().typeDependency; // maybe make transitive
  set[loc class] classes = {};
  rel[loc from, loc to] contains = m().containment;

  // get all classes in entity1
  if(isPackage(entity1)){
    for(jUnit<-contains[entity1]){
      for(class<-contains[jUnit]){
        classes += class;
      }
    }
  }
  else if(isClass(entity1)){
    classes += entity1;
  }
  
  // check the for any classes that do not import the mandatory package/class and mark them
  for(c <- classes){
    imports = false;
    set[loc] importStatements = importStatement[c];
    for(i <- importStatements){
      if(i == entity2){
        imports = true;
        break;
      }
    }
    if(!imports){msgs += warning(warn, c);}
  }
  
  return msgs;
}
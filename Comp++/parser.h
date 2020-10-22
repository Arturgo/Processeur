#ifndef PARSER_H
#define PARSER_H

#include "netlist.h"

#include <iostream>
#include <map>
#include <vector>
#include <fstream>
#include <sstream>
#include <cctype>
using namespace std;

class Stream {
private:
   ifstream fin;
   
   size_t pos;
   string content;
public:
   Stream(char* file) {
      pos = 0;
      
      fin.open(file);
      fin.tie(nullptr);
      stringstream buffer;
      buffer << fin.rdbuf();
      content = buffer.str();
      fin.close();
   }
   
   string token() {
      while(pos < content.size() && isspace(content[pos]))
         pos++;
   
      size_t end = pos;
      string r = "";
      
      while(end < content.size()) {
         if(isspace(content[end]))
            return r;
         
         if(content[end] == ':' || content[end] == ',') {
            if(r.empty())
               r.push_back(content[end]);
            return r;
         }
         
         r.push_back(content[end]);
         end++;
      }
      
      return r;
   }
   
   void next() {
      pos += token().size();
   }
};

map<string, size_t> nbArgs = {
   {"XOR", 2},
   {"OR", 2},
   {"AND", 2},
   {"NAND", 2},
   {"NOT", 1},
   {"SLICE", 3},
   {"CONCAT", 2},
   {"SELECT", 2},
   {"MUX", 3},
   {"REG", 1},
   {"RAM", 6},
   {"ROM", 3}
};

Env* parse_netlist(char* file) {
   Env* env = new Env();
   
   Stream source(file);
   
   vector<string> inputs, outputs;
   
   if(source.token() != "INPUT") {
      cerr << "Mot clé INPUT manquant" << endl;
      exit(-1);
   }
   
   //ignore INPUT
   source.next();
   
   while(true) {
      string token = source.token();
      if(token == "") {
         cerr << "Mot clé OUTPUT manquant" << endl;
         exit(-1);
      }
      if(token == "OUTPUT") {
         break;
      }
      
      if(token != ",") {
         inputs.push_back(token);
      }
      
      source.next();
   }
   
   //ignore OUTPUT
   source.next();
   
   while(true) {
      string token = source.token();
      if(token == "") {
         cerr << "Mot clé VAR manquant" << endl;
         exit(-1);
      }
      if(token == "VAR") {
         break;
      }
      
      if(token != ",") {
         outputs.push_back(token);
         env->create_output(token);
      }
      
      source.next();
   }
   
   //ignore VAR
   source.next();
   
   while(true) {
      string token = source.token();
      if(token == "") {
         cerr << "Mot clé IN manquant" << endl;
         exit(-1);
      }
      if(token == "IN") {
         break;
      }
      
      if(token != ",") {
         string var = token;
         size_t sz = 1;
         
         source.next();
         if(source.token() == ":") {
            source.next();
            
            sz = stoull(source.token());
            
            source.next();
         }
         
         env->create_node(var, sz);
      }
      else {
         source.next();
      }
   }
   
   //ignore IN
   source.next();
   
   map<string, pair<string, vector<string>>> lines;
   
   while(true) {
      string var = source.token();
      source.next();
      
      if(var.empty()) {
         break;
      }
      
      if(source.token() != "=") {
         cerr << source.token() << endl;
         cerr << "Signe = manquant" << endl;
         exit(-1);
      }
      
      source.next();
      
      string func = source.token();
      source.next();
      
      if(nbArgs.count(func) == 0) {
         lines[var] = make_pair("ARG", vector<string>({func}));
         for(size_t i = 0;i < env->sizes[var];i++) {
            env->set_node(var, i, new Nop(env->get_node(var, i)));
         }
         continue;
      }
      
      vector<string> args;
      
      size_t nbArg = nbArgs[func];
      for(size_t iArg = 0;iArg < nbArg;iArg++) {
         string x = source.token();
         source.next();
         args.push_back(x);
      }
      
      lines[var] = make_pair(func, args);
      
      if(func == "XOR") 
         env->set_node(var, 0, new Xor(env->get_node(var, 0)));
      else if (func == "OR")
         env->set_node(var, 0, new Or(env->get_node(var, 0)));
      else if (func == "AND")
         env->set_node(var, 0, new And(env->get_node(var, 0)));
      else if (func == "NAND")
         env->set_node(var, 0, new Nand(env->get_node(var, 0)));
      else if (func == "NOT")
         env->set_node(var, 0, new Not(env->get_node(var, 0)));
      else if (func == "MUX")
         env->set_node(var, 0, new Mux(env->get_node(var, 0)));
      else if (func == "SLICE") {
         size_t deb = stoull(args[0]);
         size_t fin = stoull(args[1]);
         for(size_t i = deb;i <= fin;i++) {
            env->set_node(var, i - deb, new Nop(env->get_node(var, i - deb)));
         }
      }
      else if (func == "SELECT") {
         env->set_node(var, 0, new Nop(env->get_node(var, 0)));
      }
      else if (func == "CONCAT") {
         for(size_t i = 0;i < env->sizes[var];i++) {
            env->set_node(var, i, new Nop(env->get_node(var, i)));
         }
      }
      else if (func == "REG") {
         env->set_node(var, 0, new Reg(env->get_node(var, 0)));
         env->create_ticked(var);
      }
      else if (func == "RAM" || func == "ROM") {
         for(size_t i = 0;i < stoull(args[1]);i++) {
            env->set_node(var, i, new Mem(env->get_node(var, i), stoull(args[0])));
         }
         if(func == "RAM")
            env->create_ram(var);
      }
   }
   
   for(string input : inputs) {
      env->create_input(input);
   }
   
   //Link nodes together
   for(pair<string, pair<string, vector<string>>> line : lines) {
      string var = line.first;
      string func = line.second.first;
      vector<string> args = line.second.second;
      
      if(func == "XOR" || func == "OR" || func == "AND" || func == "NAND" || func == "NOT" || func == "MUX" || func == "REG") {
         for(string arg : args) {
            env->add_parent(var, 0,
               env->get_node(arg, 0)
            );
         }
      }
      else if(func == "SLICE") {
         size_t deb = stoull(args[0]);
         size_t fin = stoull(args[1]);
         for(size_t i = deb;i <= fin;i++) {
            env->add_parent(var, i - deb,
               env->get_node(args[2], i)
            );
         }
      }
      else if(func == "SELECT") {
         env->add_parent(var, 0,
            env->get_node(args[1], stoull(args[0]))
         );
      }
      else if(func == "CONCAT") {
         for(size_t i = 0;i < env->sizes[args[0]];i++) {
            env->add_parent(var, i,
               env->get_node(args[0], i)
            );
         }
         
         for(size_t i = 0;i < env->sizes[args[1]];i++) {
            env->add_parent(var, i + env->sizes[args[0]],
               env->get_node(args[1], i)
            );
         }
      }
      else if(func == "ROM" || func == "RAM") {
         for(size_t i = 0;i < stoull(args[1]);i++) {
            for(size_t j = 0;j < stoull(args[0]);j++) {
               env->add_parent(var, i,
                  env->get_node(args[2], j)
               );
            }
            
            
            if(func == "RAM") {
               env->add_parent(var, i,
                  env->get_node(args[3], 0)
               );
               
               for(size_t j = 0;j < stoull(args[0]);j++) {
                  env->add_parent(var, i,
                     env->get_node(args[4], j)
                  );
               }
               
               env->add_parent(var, i,
                  env->get_node(args[5], i)
               );
            }
         }
      }
      else if(func == "ARG") {
         for(size_t i = 0;i < env->sizes[var];i++) {
            env->add_parent(var, i,
               env->get_node(args[0], i)
            );
         }
      }
   }
   
   #ifdef VERBOSE
   cerr << "Lecture du netlist réussie !" << endl;
   cerr << "Entrees : " << endl;
   
   for(string input : inputs) {
      cerr << "-> " << input << endl;
   }
   
   cerr << "Sorties : " << endl;
   
   for(string output : outputs) {
      cerr << "-> " << output << endl;
   }
   
   cerr << "Variables : " << endl;
   
   for(pair<string, size_t> var : env->sizes) {
      cerr << "-> " << var.first << " (" << var.second << ")" << endl;
   }
   
   #endif
   
   env->opt();
   return env;
}

#endif

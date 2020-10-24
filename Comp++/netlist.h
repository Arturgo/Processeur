#ifndef NETLIST_H
#define NETLIST_H

#include <map>
#include <vector>
#include <cstdlib>
#include <ctime>
#include <string>
using namespace std;

size_t curTick = 0;

/* Check arrays */
bool is_boolarray(string s) {
   for(char car : s) {
      if(car != '0' && car != '1')
         return false;
   }
   return true;
}

/* Var name functions */

string f(size_t id) {
   return "_calc_" + to_string(id) + "()"; 
}

string der(size_t id) {
   return "derTick_" + to_string(id); 
}

string val(size_t id) {
   return "val_" + to_string(id); 
}

string tmp(size_t id) {
   return "tmp_" + to_string(id); 
}

string mem(size_t id) {
   return "mem_" + to_string(id); 
}

/* Virtual definition of node */

class Node {
public:
   size_t derTick = 0;
   size_t nbUses = 0;
   
   size_t seed;
   
   size_t id;
   vector<Node*> parents;
   
   /* How calculation are dynamised */
   Node(size_t _id) {
      id = _id;
      seed = rand();
   }
   
   virtual string just_op() { return ""; };
   
   virtual string vars() {
      if(nbUses <= 1)
         return "";
      return "bool " + f(id) + ";\n"
      + "size_t " + der(id) + " = 0;\n"
      + "bool " + val(id) + " = 0;\n"
      + "bool " + tmp(id) + " = 0;\n"; 
   }
   
   virtual string code() {
      if(nbUses <= 1)
         return "";
      return "inline bool " + f(id) + " {\n"
         + "if(" + der(id) + " == curTick) return " + val(id) + ";\n"
         + der(id) + " = curTick;\n"
         + val(id) + " = " + just_op() + ";\n"
         + "return " + val(id) + ";\n"
      + "}\n";
   }
   
   virtual string call() {
      if(nbUses <= 1)
         return "(" + just_op() + ")";
      return f(id);
   }
   
   virtual string tick() { return ""; }
   
   virtual string tack() { return ""; }
   
   virtual Node* opt() {
      if(curTick == derTick) return this;
      derTick = curTick;
      
      for(size_t iParent = 0;iParent < parents.size();iParent++) {
         parents[iParent] = parents[iParent]->opt();
      }
      return this;
   }
   
   virtual ~Node() {};
};

/* Definition of types */

class Const : public Node {
public:
   string just_op() { 
      if(id == 0) return "0";
      if(id == 1) return "1";
      return val(id); 
   }
   string vars() { return "bool " + val(id) + " = 0;\n"; }
   string code() { return ""; }
   string call() { return just_op(); }
   
   Const(size_t _id) : Node(_id) {}
};

class Xor : public Node {
public:
   string just_op() {
      return parents[0]->call() + " ^ " + parents[1]->call();
   }
   Xor(size_t _id) : Node(_id) {}
};

class Or : public Node {
public:
   string just_op() {
      return parents[0]->call() + " || " + parents[1]->call();
   }
   Or(size_t _id) : Node(_id) {}
};

class And : public Node {
public:
   string just_op() {
      return parents[0]->call() + " && " + parents[1]->call();
   }
   And(size_t _id) : Node(_id) {}
};

class Nand : public Node {
public:
   string just_op() {
      return "!" + parents[0]->call() + " || !" + parents[1]->call();
   }
   Nand(size_t _id) : Node(_id) {}
};

class Not : public Node {
public:
   string just_op() {
      return "!" + parents[0]->call();
   }
   Not(size_t _id) : Node(_id) {}
};

class Mux : public Node {
public:
   string just_op() {
      return "((" + parents[0]->call() + ")?(" + parents[2]->call() + "):(" + parents[1]->call() + "))";
   }
   Mux(size_t _id) : Node(_id) {}
};

class Nop : public Node {
public:
   Node* opt() {
      if(derTick == curTick) return parents[0];
      derTick = curTick;
      return (parents[0] = parents[0]->opt());
   }

   string just_op() {
      return parents[0]->call();
   }
   
   Nop(size_t _id) : Node(_id) {}
};

class Reg : public Node {
public:
   string tick() {
      return tmp(id) + " = " + parents[0]->call() + ";\n";
   }
   
   string tack() {
      return val(id) + " = " + tmp(id) + ";\n";
   }
   
   string just_op() { return val(id); }
   string vars() { return "bool " + val(id) + " = 0;\n"
   + "bool " + tmp(id) + " = 0;\n"; }
   string code() { return ""; }
   string call() { return just_op(); }
   
   Reg(size_t _id) : Node(_id) {}
};

class Mem : public Node {
public:
   size_t adsz;
   
   Mem(size_t _id, size_t _addr_size) : Node(_id) {
      adsz = _addr_size;
   }
   
   string vars() {
      return "bitset<" + to_string((1 << adsz)) + "> " + mem(id) + " = 0;\n"
      + "bool " + f(id) + ";\n"
      + "size_t " + der(id) + " = 0;\n"
      + "bool " + val(id) + " = 0;\n"
      + "bool " + tmp(id) + " = 0;\n";
   }
   
   string code() {
      string c = "inline bool " + f(id) + " {\n"
      + "if(" + der(id) + " == curTick) return " + val(id) + ";\n"
      + der(id) + " = curTick;\n"
      + "size_t pos = 0;\n";
      for(size_t i = 0;i < adsz;i++) {
         c += "if(" + parents[i]->call() + ") pos |= " + to_string(1 << i) + ";\n";
      }
      c += "return " + val(id) + " = " + mem(id) + "[pos];\n"
      + "}\n";
      return c;
   }
   
   string call() { return f(id); }
   
   string tick() { return ""; }
};

/* Defintion of environment */

class Env {
public:
   size_t cur_code;
   map<string, size_t> codes, sizes;
   
   vector<string> inputs, outputs;
   vector<size_t> ticked_pins;
   vector<string> rams;
   
   vector<Node*> node_list;

   Env() {
      node_list.push_back(new Const(0));
      node_list.push_back(new Const(1));
      
      sizes["0"] = sizes["1"] = 1;
      codes["0"] = 0;
      codes["1"] = 1;
      
      cur_code = 2;
   }
   
   ~Env() {
      for(Node* node : node_list) {
         delete node;
      }
   }
   
   void create_node(string name, size_t size) {
      codes[name] = cur_code;
      sizes[name] = size;
      
      cur_code += size;
      
      size_t begin = node_list.size();
      for(size_t i = 0;i < size;i++) {
         node_list.push_back(new Nop(begin + i));
         node_list.back()->parents.push_back(node_list[0]);
      }
   }
   
   void create_output(string name) {
      outputs.push_back(name);
   }
   
   void create_ticked(string name) {
      for(size_t i = 0;i < sizes[name];i++) {
         ticked_pins.push_back(codes[name] + i);
      }
   }
   
   void create_ram(string name) {
      rams.push_back(name);
   }
   
   void create_input(string name) {
      inputs.push_back(name);
      
      for(size_t i = 0;i < sizes[name];i++) {
         set_node(name, i, new Const(codes[name] + i));
      }
   }
   
   size_t get_node(string name, size_t pos = 0) {
      if(is_boolarray(name)) {
         return name[pos] - '0';   
      }
      
      if(pos >= sizes[name]) {
         cerr << "Accès en dehors du tableau pour : " << name << "[" << pos << "]" << endl;
         exit(-1);
      }
      
      return codes[name] + pos;
   }
   
   void set_node(string name, size_t pos, Node* node) {
      node_list[get_node(name, pos)] = node;
   }
   
   void add_parent(string name, size_t pos, size_t parent) {
      node_list[get_node(name, pos)]->parents.push_back(node_list[parent]);
   }
   
   void opt() {
      curTick++;
      
      for(Node* node : node_list) {
         node->opt();
      }
   }
   
   string code() {
      string c = "#ifndef PROC_H\n";
      c += "#define PROC_H\n";
      c += "#include <iostream>\n";
      c += "#include <bitset>\n";
      c += "#include <fstream>\n";
      c += "#include <vector>\n";
      c += "using namespace std;\n\n";
      
      opt();
      
      //Compute uses
      
      for(Node* node : node_list) {
         if(node->opt()->id == node->id) {
            for(Node* parent : node->parents) {
               parent->nbUses++;
            }
         }
      }
      
      for(string output : outputs) {
         for(size_t i = 0;i < sizes[output];i++) {
            node_list[codes[output] + i]->nbUses++;
         }
      }
      
      size_t nbUsed = 0, nbUsedTwice = 0;
      for(Node* node : node_list) {
         if(node->opt()->id == node->id && node->nbUses > 0) {
            nbUsed++;
            
            if(node->nbUses > 1) {
               nbUsedTwice++;
            }
         }
      }
      
      cerr << "NbUsed : " << nbUsed << endl;
      cerr << "NbUsedTwice : " << nbUsedTwice << endl;
      
      //Netlist Nodes
      for(size_t node = 0;node < node_list.size();node++) {
         if(node_list[node]->opt()->id == node) {
            c += node_list[node]->vars();
         }
      }
      
      c += "size_t curTick = 0;\n\n";
      
      for(Node* node : node_list) {
         if(node->opt()->id == node->id)
            c += node->code();
      }
      
      //RAM initialization
      
      c += "void init_ram() {\n";
      c += "string file;\n";
      c += "ifstream fin;\n";
      c += "char c;\n";
      c += "size_t pos = 0;\n";
      for(string ram : rams) {
         c += "cerr << \"Please indicate a file to init ram " + ram + ":\" << endl;\n;";
         c += "cin >> file;\n";
         c += "fin.open(file);\n";
         c += "pos = 0;\n";
         
         c += "while(true) {\n";
         for(size_t i = 0;i < sizes[ram];i++) {
            c += "fin >> c;\n";
            c += "if(fin.fail()) break;\n";
            c += mem(codes[ram] + i) + "[pos] = c - '0';\n";
         }
         c += "pos++;";
         
         c += "}\n";
         c += "fin.close();\n";
      }
      c += "}\n";
      
      if(rams.size() == 1) {
         c += "size_t get_ram(size_t pos) {\n";
         string ram = rams.back();
         c += "bitset<" + to_string(sizes[ram]) + "> x;\n";
         c += "bitset<128> mask((((size_t)1) << 32) - 1);\n";
         
         for(size_t i = 0;i < sizes[ram];i++) {
            c += "x[" + to_string(i) + "] = " + mem(codes[ram] + i) + "[pos >> 2];\n";
         }

         c += "return ((x >> (32 * (pos % 4))) & mask).to_ulong();\n";
         c += "}\n";
      }
      
      //Tick function
      c += "void tick() {\n";
      c += "val_0 = 0; val_1 = 1;\n";
      c += "char c;\n";
      c += "size_t pos = 0;\n";
      
      c += "curTick++;\n";
      
      for(string input : inputs) {
         c += "#ifdef INPUT\n";
         c += "cerr << \"Input for " + input + " (" + to_string(sizes[input]) + ") ?\" << endl;\n";
         c += "#endif\n";
         
         for(size_t i = 0;i < sizes[input];i++) {
            c += "cin >> c;\n";
            c += val(codes[input] + i) + " = c - '0';\n";
         }
      }
      
      c += "#ifdef OUTPUT\n";
      for(string output : outputs) {
         c += "cout << \"Output for " + output + "\" << endl;\n";
         for(size_t i = 0;i < sizes[output];i++) {
            c += "cout << " + node_list[codes[output] + i]->opt()->call() + ";\n";
         }
         c += "cout << endl;\n";
      }
      c += "#endif\n";
      
      for(size_t ticked : ticked_pins) {
         c += node_list[ticked]->tick();
      }
      
      for(string ram : rams) {
         size_t id = codes[ram];
         Mem* repr = (Mem*)node_list[id];
         
         c += "if(" + repr->parents[repr->adsz]->call() + ") {\n"
         + "pos = 0;\n";
         for(size_t i = 0;i < repr->adsz;i++) {
            c += "if(" + repr->parents[i + repr->adsz + 1]->call() + ") pos |= " + to_string(1 << i) + ";\n";
         }
         for(size_t i = 0;i < sizes[ram];i++) {
            c += node_list[id + i]->call() + ";\n";
            c += mem(id + i) + "[pos] = " + node_list[id + i]->parents.back()->call() + ";\n";
         }
         c += "}\n";
      }
      
      for(size_t ticked : ticked_pins) {
         c += node_list[ticked]->tack();
      }

      c += "}\n";
      
      c += "#endif\n";
      
      return c;
   }
};

#endif

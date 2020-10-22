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
   
   size_t id;
   vector<size_t> parents;
   
   /* How calculation are dynamised */
   Node(size_t _id) {
      id = _id;
   }
   
   virtual string just_op() { return ""; };
   
   virtual string code() {
      return 
        "inline bool " + f(id) + " {\n"
         + "if(" + der(id) + " == curTick) return " + val(id) + ";\n"
         + der(id) + " = curTick;\n"
         + val(id) + " = " + just_op() + ";\n"
         + "return " + val(id) + ";\n"
      + "}\n";
   }
   
   virtual string init() { return ""; }
   
   virtual string tick() { return ""; }
   
   virtual string tack() { return ""; }
   
   virtual size_t opt(vector<Node*>::iterator dec) {
      if(curTick == derTick) return id;
      derTick = curTick;
      for(size_t iParent = 0;iParent < parents.size();iParent++) {
         parents[iParent] = (*(dec + parents[iParent]))->opt(dec);
      }
      return id;
   }
   
   virtual ~Node() {};
};

/* Definition of types */

class Const : public Node {
public:
   bool v;
   
   string just_op() {
      return val(id);
   }
   
   string code() {
      return 
        "inline bool " + f(id) + " {\n"
         + "return " + val(id) + ";\n"
      + "}\n";
   }
   
   Const(size_t _id, bool _v) : Node(_id) {
      v = _v;
   }
};

class Xor : public Node {
public:
   string just_op() {
      return f(parents[0]) + " ^ " + f(parents[1]);
   }
   Xor(size_t _id) : Node(_id) {}
};

class Or : public Node {
public:
   string just_op() {
      return f(parents[0]) + " || " + f(parents[1]);
   }
   Or(size_t _id) : Node(_id) {}
};

class And : public Node {
public:
   string just_op() {
      return f(parents[0]) + " && " + f(parents[1]);
   }
   And(size_t _id) : Node(_id) {}
};

class Nand : public Node {
public:
   string just_op() {
      return "!" + f(parents[0]) + " || !" + f(parents[1]);
   }
   Nand(size_t _id) : Node(_id) {}
};

class Not : public Node {
public:
   string just_op() {
      return "!" + f(parents[0]);
   }
   Not(size_t _id) : Node(_id) {}
};

class Mux : public Node {
public:
   string just_op() {
      return "((" + f(parents[0]) + ")?(" + f(parents[2]) + "):(" + f(parents[1]) + "));";
   }
   Mux(size_t _id) : Node(_id) {}
};

class Nop : public Node {
public:
   size_t opt(vector<Node*>::iterator dec) {
      if(derTick == curTick) return parents[0];
      derTick = curTick;
      return (parents[0] = (*(dec + parents[0]))->opt(dec));
   }

   string just_op() {
      return f(parents[0]);
   }
   
   Nop(size_t _id) : Node(_id) {}
};

class Reg : public Node {
public:
   string tick() {
      return tmp(id) + " = " + f(parents[0]) + ";\n";
   }
   
   string tack() {
      return val(id) + " = " + tmp(id) + ";\n";
   }
   
   string code() {
      return 
        "inline bool " + f(id) + " {\n"
         + "return " + val(id) + ";\n"
      + "}\n";
   }
   
   Reg(size_t _id) : Node(_id) {}
};

class Mem : public Node {
public:
   size_t adsz;
   
   Mem(size_t _id, size_t _addr_size) : Node(_id) {
      adsz = _addr_size;
   }
   
   string init() {
      return "bitset<" + to_string((1 << adsz)) + "> " + mem(id) + " = 0;\n";
   }
   
   string code() {
      string c = "inline bool " + f(id) + " {\n"
      + "if(" + der(id) + " == curTick) return " + val(id) + ";\n"
      + der(id) + " = curTick;\n"
      + "size_t pos = 0;\n";
      for(size_t i = 0;i < adsz;i++) {
         c += "if(" + f(parents[i]) + ") pos |= " + to_string(1 << i) + ";\n";
      }
      c += "return " + val(id) + " = " + mem(id) + "[pos];\n"
      + "}\n";
      return c;
   }
   
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
      node_list.push_back(new Const(0, false));
      node_list.push_back(new Const(1, true));
      
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
         node_list.back()->parents.push_back(0);
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
         set_node(name, i, new Const(codes[name] + i, false));
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
      node_list[get_node(name, pos)]->parents.push_back(parent);
   }
   
   void opt() {
      curTick++;
      
      for(Node* node : node_list) {
         node->opt(node_list.begin());
      }
   }
   
   string code() {
      string c = "#include <iostream>\n";
      c += "#include <bitset>\n";
      c += "#include <fstream>\n";
      c += "#include <vector>\n";
      c += "using namespace std;\n\n";
      
      opt();
      
      /* init variables and functions */
      for(size_t node = 0;node < node_list.size();node++) {
         if(node_list[node]->opt(node_list.begin()) == node) {
            c += node_list[node]->init();
            c += "bool " + f(node) + ";\n";
            c += "size_t " + der(node) + " = 0;\n";
            c += "bool " + val(node) + " = 0;\n";
            c += "bool " + tmp(node) + " = 0;\n";
         }
      }
      
      c += "size_t curTick = 0;\n\n";
      
      for(Node* node : node_list) {
         if(node->opt(node_list.begin()) == node->id)
            c += node->code();
      }
      
      c += "int main(int argc, char* argv[]) {\n";
      c += "ios_base::sync_with_stdio(false); cin.tie(nullptr); cout.tie(nullptr);\n";
      c += "size_t nbTicks = stoull(argv[1]);\n";
      c += "val_0 = 0; val_1 = 1;\n";
      c += "char c;\n";
      
      c += "string file;\n";
      c += "ifstream fin;\n";
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
      
      c += "while(curTick < nbTicks) {\n";
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
            c += "cout << " + f(node_list[codes[output] + i]->opt(node_list.begin())) + ";\n";
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
         
         c += "if(" + f(repr->parents[repr->adsz]) + ") {\n"
         + "size_t pos = 0;\n";
         for(size_t i = 0;i < repr->adsz;i++) {
            c += "if(" + f(repr->parents[i + repr->adsz + 1]) + ") pos |= " + to_string(1 << i) + ";\n";
         }
         for(size_t i = 0;i < sizes[ram];i++) {
            c += f(id + i) + ";\n";
            c += mem(id + i) + "[pos] = " + f(node_list[id + i]->parents.back()) + ";\n";
         }
         c += "}\n";
      }
      
      for(size_t ticked : ticked_pins) {
         c += node_list[ticked]->tack();
      }

      c += "}\n";
      
      c += "#ifdef DEBUG_RAM\n";
      
      for(string ram : rams) {
         c += "size_t nb = 0;\n";
         c += "cerr << \"Number of words to print for ram " + ram + ":\" << endl;\n;";
         c += "cin >> nb;\n";
         
         c += "for(size_t i = 0;i < nb;i++) {\n";
         for(size_t j = 0;j < 4;j++) {
            c += "bitset<" + to_string(sizes[ram]) + "> x_" + to_string(j) + ";\n";
            for(size_t i = 0;i < 32;i++) {
               c += "x_" + to_string(j) + "[" + to_string(i) + "] = " + mem(codes[ram] + 32 * j + i) + "[i];\n";
            }
            c += "cerr << 4 * i + " + to_string(j) +" << \": \" << x_" + to_string(j) + ".to_ulong() << endl;\n";
         }
         c += "}\n";
      }
      
      c += "#endif\n";
      
      c += "return 0;\n";
      c += "}\n";
      
      return c;
   }
};

#endif

#ifndef UTILS_H
#define UTILS_H

#include <map>
#include <vector>
#include <string>
#include <iostream>
using namespace std;

string prog;
map<string, size_t> vars;
vector<string> outputs;

void write() {
   cout << "INPUT" << endl;
   cout << "OUTPUT" << endl;
   
   bool first;
   
   first = true;
   for(string output : outputs) {
      if(!first) {
         cout << ", ";
      }
      cout << output;
      first = false;
   }
   cout << endl;
   
   cout << "VAR" << endl;
   
   first = true;
   for(pair<string, size_t> var : vars) {
      if(!first) {
         cout << ", ";
      }
      cout << var.first;
      
      if(var.second != 1) {
         cout << " : " << var.second;
      }
      
      first = false;
   }
   cout << endl;
   
   cout << "IN" << endl;
   cout << prog << endl;
}


string decl_var(size_t size = 1) {
   string name = "_l_" + to_string(vars.size());
   vars[name] = size;
   return name;
}

void decl_output(string name) {
   outputs.push_back(name);
}

vector<string> init(size_t size) {
   vector<string> fils;
   for(size_t iBit = 0;iBit < size;iBit++) {
      fils.push_back(decl_var());
   }
   return fils;
}

void ram(string output, size_t addr_size, size_t word_size, string read, string update, string addr, string data) {
   prog += output + " = RAM " + to_string(addr_size) + " " + to_string(word_size) + " " + read + " " + update + " " + addr + " " + data + "\n";
}

void mux(string output, string x, string y, string select) {
   prog += output + " = MUX " + select + " " + x + " " + y + "\n";
}

void select(string output, string input, size_t index) {
   prog += output + " = SELECT " + to_string(index) + " " + input + "\n";
}

void assign(string output, string input) {
   prog += output + " = " + input + "\n";
}

void reg(string output, string input) {
   prog += output + " = REG " + input + "\n";
}

string op_not(string input) {
   string output = decl_var();
   prog += output + " = NOT " + input + "\n";
   return output;
}

string concat(vector<string> wires) {
   if(wires.size() == 1) {
      return wires[0];
   }
   
   string output = decl_var(wires.size());
   
   string nouv = wires.back();
   wires.pop_back();
   
   prog += output + " = CONCAT " + concat(wires) + " " + nouv + "\n";
   return output;
}

string mux(string x, string y, string select) {
   string output = decl_var();
   mux(output, x, y, select);
   return output;
}

vector<string> mux(vector<string> x, vector<string> y, string select) {
   vector<string> output;
   
   for(size_t iBit = 0;iBit < x.size();iBit++) {
      output.push_back(mux(x[iBit], y[iBit], select));
   }
   
   return output;
}

void memory(string output, string input, string update) {
   string nouv = mux(output, input, update);
   prog += output + " = REG " + nouv + "\n";
}

string select(string input, size_t index) {
   string output = decl_var();
   select(output, input, index);
   return output;
}

string op_xor(string a, string b) {
   string output = decl_var();
   prog += output + " = XOR " + a + " " + b + "\n";
   return output;
}

string op_or(string a, string b) {
   string output = decl_var();
   prog += output + " = OR " + a + " " + b + "\n";
   return output;
}

string op_and(string a, string b) {
   string output = decl_var();
   prog += output + " = AND " + a + " " + b + "\n";
   return output;
}

vector<string> selector(vector<vector<string>> inputs, vector<string> addr) {
   if(inputs.size() == 1)
      return inputs[0];
   
   vector<vector<string>> fusion;
   
   for(size_t iInput = 0;iInput < inputs.size() / 2;iInput++) {
      fusion.push_back(vector<string>());
      for(size_t iBit = 0;iBit < inputs[0].size();iBit++) {
         fusion.back().push_back(mux(inputs[iInput][iBit], inputs[iInput + inputs.size() / 2][iBit], addr.back()));
      }
   }
   
   addr.pop_back();
   
   return selector(fusion, addr);
}

vector<string> dispatcher(vector<string> addr) {
   vector<string> outputs((1 << addr.size()), "1");
   
   for(size_t iBit = 0;iBit < addr.size();iBit++) {
      string yes = addr[iBit];
      string no = op_not(addr[iBit]);
      for(size_t i = 0;i < outputs.size();i++) {
         if((i >> iBit) % 2 == 0)
            outputs[i] = op_and(outputs[i], no);
         else 
            outputs[i] = op_and(outputs[i], yes);
      }
   }
   
   return outputs;
}

vector<string> add_bits(vector<string> a, vector<string> b) {
   string r = "0";
   
   vector<string> res;
   for(size_t iBit = 0;iBit < a.size();iBit++) {
      res.push_back(op_xor(r, op_xor(a[iBit], b[iBit])));
      r = op_or(op_and(a[iBit], b[iBit]), op_and(r, op_or(a[iBit], b[iBit])));
   }
   
   return res;
}

vector<string> inc_bits(vector<string> a) {
   string r = "1";
   
   vector<string> res;
   for(size_t iBit = 0;iBit < a.size();iBit++) {
      res.push_back(op_xor(r, a[iBit]));
      r = op_and(r, a[iBit]);
   }
   
   return res;
}

vector<string> not_bits(vector<string> a) {
   vector<string> res;
   for(size_t iBit = 0;iBit < a.size();iBit++) {
      res.push_back(op_not(a[iBit]));
   }
   return res;
}

vector<string> xor_bits(vector<string> a, vector<string> b) {
   vector<string> res;
   for(size_t iBit = 0;iBit < a.size();iBit++) {
      res.push_back(op_xor(a[iBit], b[iBit]));
   }
   return res;
}

vector<string> or_bits(vector<string> a, vector<string> b) {
   vector<string> res;
   for(size_t iBit = 0;iBit < a.size();iBit++) {
      res.push_back(op_or(a[iBit], b[iBit]));
   }
   return res;
}

vector<string> and_bits(vector<string> a, vector<string> b) {
   vector<string> res;
   for(size_t iBit = 0;iBit < a.size();iBit++) {
      res.push_back(op_and(a[iBit], b[iBit]));
   }
   return res;
}

vector<string> neg_bits(vector<string> a) {
   return inc_bits(not_bits(a));
}

vector<string> sub_bits(vector<string> a, vector<string> b) {
   return add_bits(a, neg_bits(b));
}

vector<string> mul_p2_bits(vector<string> bits, size_t dec) {
   vector<string> res(dec, "0");
   
   for(size_t iBit = 0;res.size() < bits.size();iBit++) {
      res.push_back(bits[iBit]);
   }
   
   return res;
}

vector<string> mul_bits(vector<string> a, vector<string> b) {
   vector<string> res(a.size(), "0");
   
   for(size_t iBit = 0;iBit < a.size();iBit++) {
      res = add_bits(res, mux(vector<string>(b.size(), "0"), mul_p2_bits(b, iBit), a[iBit]));
   }
   
   return res;
}

string is_zero(vector<string> a) {
   string res = op_not(a[0]);
   
   for(size_t iBit = 1;iBit < a.size();iBit++) {
      res = op_and(op_not(a[iBit]), res);
   }
   
   return res;
}

#endif 

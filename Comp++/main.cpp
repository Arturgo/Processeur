#include <iostream>
#include "parser.h"
using namespace std;

int main(int argc, char* argv[]) {
   ios_base::sync_with_stdio(false);
   
   //get number of turns
   if(argc <= 1) {
      cerr << "Veuillez donner un nom de fichier" << endl;
      return -1;
   }
   
   Env* env = parse_netlist(argv[1]);
   cout << env->code() << endl;
   return 0;
}

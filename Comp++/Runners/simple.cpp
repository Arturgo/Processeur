#include "proc.h"
#include <iostream>

using namespace std;

int main(int argc, char* argv[]) {
   ios_base::sync_with_stdio(false);
   cin.tie(nullptr);
   cout.tie(nullptr);
   
   cout << "Nombre de ticks à exécuter ?" << endl;
   size_t nbTicks;
   cin >> nbTicks;
   
   init_ram();
   
   for(size_t iTick = 0;iTick < nbTicks;iTick++) {
      tick();
   }
   
   return 0;
}

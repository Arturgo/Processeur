#include "proc.h"
using namespace std;

int main(int argc, char* argv[]) {
   ios_base::sync_with_stdio(false);
   cin.tie(nullptr);
   cout.tie(nullptr);
   
   init_ram();
   for(size_t i = 0;i < 100;i++) {
      tick();
   }
   
   for(size_t i = 0;i < 100;i++) {
      cerr << i << ": " << get_ram(i) << endl;
   }
}

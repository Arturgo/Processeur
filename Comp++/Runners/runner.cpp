#include <SFML/Graphics.hpp>
#include "proc.h"
#include <iostream>
#include <chrono>
#include <ctime>
#include <cstdlib>
#include <cstdio>

using namespace std;
using namespace sf;

int main(int argc, char* argv[]) {
   ios_base::sync_with_stdio(false);
   cin.tie(nullptr);
   cout.tie(nullptr);
   
   init_ram();
   
   const size_t REAL_X = 800;
   const size_t REAL_Y = 600;
   const size_t SCREEN_X = 64;
   const size_t SCREEN_Y = 48;
   const float SIZE_X = REAL_X / (float)SCREEN_X;
   const float SIZE_Y = REAL_Y / (float)SCREEN_Y;
   
   sf::RenderWindow window(sf::VideoMode(REAL_X, REAL_Y), "SCREEN");
   
   size_t derValue = 0;
   size_t addr_begin = (1 << 23);
   size_t addr_update = addr_begin + SCREEN_X * SCREEN_Y;
   size_t addr_keyboard = addr_update + 1;
   size_t addr_minutes = addr_update + 2;
   size_t addr_milliseconds = addr_update + 3;
   size_t addr_switch = addr_update + 4;
   
   size_t iTick = 0;
   
   size_t deb = clock();
   while(window.isOpen()) {
      sf::Event event;
      while(window.pollEvent(event)) {
         if(event.type == sf::Event::Closed)
            window.close();
         if(event.type == sf::Event::KeyPressed) {
            set_ram(addr_keyboard, event.key.code);
         }
      }
      
      unsigned long long now = chrono::duration_cast<chrono::milliseconds>(chrono::system_clock::now().time_since_epoch()).count();
      
      set_ram(addr_minutes, now / 60000);
      set_ram(addr_milliseconds, now % 60000);
      set_ram(addr_switch, (now / 1000) % 2);
      
      tick();
      iTick++;
      
      size_t curValue = get_ram(addr_update);
      if(derValue != curValue) {
         window.clear();
         
         for(size_t iX = 0;iX < SCREEN_X;iX++) {
            for(size_t iY = 0;iY < SCREEN_Y;iY++) {
               RectangleShape pixel(Vector2f(SIZE_X, SIZE_Y));
               pixel.setFillColor(Color(get_ram(addr_begin + iX + iY * SCREEN_X)));
               pixel.setPosition(iX * SIZE_X, iY * SIZE_Y);
               window.draw(pixel);
            }
         }
         
         window.display();
         
         derValue = curValue;
      }
   }
   
   size_t fin = clock();
   
   cerr << iTick << " ticks executed in " << (fin - deb) / (double)CLOCKS_PER_SEC << " seconds." << endl;
   
   return 0;
}

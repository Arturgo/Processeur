#include <SFML/Graphics.hpp>
#include "proc.h"
#include <iostream>

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
   
   while(window.isOpen()) {
      sf::Event event;
      while(window.pollEvent(event)) {
         if(event.type == sf::Event::Closed)
            window.close();
      }
      
      for(size_t iTick = 0;iTick < 5000;iTick++) {
         tick();
      }
      
      window.clear();
      
      size_t addr_begin = 0;
      for(size_t iX = 0;iX < SCREEN_X;iX++) {
         for(size_t iY = 0;iY < SCREEN_Y;iY++) {
            RectangleShape pixel(Vector2f(SIZE_X, SIZE_Y));
            pixel.setFillColor(Color(get_ram(iX + iY * SCREEN_X)));
            pixel.setPosition(iX * SIZE_X, iY * SIZE_Y);
            window.draw(pixel);
         }
      }
      
      window.display();
   }
   
   return 0;
}

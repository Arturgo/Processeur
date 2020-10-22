#!/bin/bash

g++ -o main main.cpp -Wall -std=c++11 -O2
./main > proc.net
./../Comp++/main proc.net > proc.cpp
g++ -o proc proc.cpp -Wall -std=c++11 -DOUTPUT -DDEBUG_RAM
echo "ram.data 10" | ./proc 100

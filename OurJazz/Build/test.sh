#!/bin/bash

cp ../utils.h utils.h
cp ../main.cpp main.cpp
g++ -o main main.cpp -Wall -std=c++11 -O2

./main > proc.net
./../../Comp++/main proc.net > proc.h
cp ../../Comp++/Runners/runner.cpp runner.cpp

g++ -o proc runner.cpp -Wall -std=c++11 -Ofast -lsfml-window -lsfml-graphics -lsfml-system -DOUTPUT -DINPUT

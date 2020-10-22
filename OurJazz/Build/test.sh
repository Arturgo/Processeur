#!/bin/bash

cp ../main.cpp main.cpp
cp ../utils.h utils.h

g++ -o main main.cpp -Wall -std=c++11 -O2
./main > proc.net
./../../Comp++/main proc.net > proc.h

cp ../../Comp++/Runners/runner.cpp runner.cpp
g++ -o proc runner.cpp -Wall -std=c++11 -Ofast -DOUTPUT -DINPUT

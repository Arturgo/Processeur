#!/bin/bash

cp ../Runners/simple.cpp simple.cpp

../main $1 > proc.h

g++ -o proc simple.cpp -Wall -std=c++11 -Ofast -DOUTPUT -DINPUT

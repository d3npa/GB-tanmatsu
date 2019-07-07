#!/bin/sh

rm main.o main.gb
rgbasm -o main.o code/main.z80.asm
rgblink -o main.gb main.o
rgbfix -v -p0 main.gb

# Makefile for hog application
# To run app you have to have sudo perimission

SHELL = /bin/bash
CC = g++
OUTPUT = -o
EXEC = hog

all: hog.cpp
	$(CC) hog.cpp $(OUTPUT) $(EXEC)

run: 
	sudo ./$(EXEC)

clean: hog
	rm $(EXEC)




#!/bin/bash  
read -p "Enter the word to grep: "  word
grep -r --exclude-dir=log $word .

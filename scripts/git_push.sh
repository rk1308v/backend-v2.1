#!/bin/bash  
git status ;
git add . ;
read -p "Enter commit message: " message
git commit -m $message ;
git status ;
git push heroku master;
git status ;

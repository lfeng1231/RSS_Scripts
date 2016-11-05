#!/usr/bin/env bash

DIR=$(pwd)

for sample in "" "" "" 
do
    cd "$DIR/$sample"
    sh /home/users/fengl6/my_scripts/26_clean_up/clean_legacy.sh
    echo "$sample finished"
done

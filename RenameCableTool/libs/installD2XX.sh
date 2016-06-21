#!/bin/sh

# installD2XX.sh
# 
#
# Created by Alan Ding on 2/6/11.
# Copyright 2011 Apple. All rights reserved.

# script to install D2XX libraries

#echo "Please enter: "
#echo "1 for OSX 10.5/6 or later D2XX Driver"
#echo "2 for OSX 10.4 D2XX Driver"
#read number
#if [ $number -eq 1 ]
#then
sudo cp ./libftd2xx.1.0.2.dylib /usr/local/lib
sudo cp ./libd2xx_table.dylib /usr/local/lib

cd /usr/local/lib

sudo ln -sf libftd2xx.1.0.2.dylib libftd2xx.dylib
#elif [ $number -eq 2 ]
#then
#sudo cp ./libftd2xx.1.0.2-2.dylib /usr/local/lib
#sudo cp ./libd2xx_table.dylib /usr/local/lib

#cd /usr/local/lib

#sudo ln -sf libftd2xx.1.0.2-2.dylib libftd2xx.dylib
#else
#echo "Wrong input"
#fi
#!/bin/bash -f

yes | rm -r development
yes | rm -r bin

git clone git://github.com/bkjeholt/development.git

chmod 755 development/bin/*

ln -s development/bin bin

if [ ! -f .build-counter ]
  then
    cp development/.build-counter . 
fi

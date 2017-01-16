#!/bin/bash -f

yes | rm -r development
yes | rm -r bin

git clone git://github.com/bkjeholt/development.git

chmod 755 development/bin/*

ln -s development/bin bin

cp development/.build-counter . 

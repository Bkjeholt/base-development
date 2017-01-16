#!/bin/bash -f

rm -r development
rm -r bin

git clone git://github.com/bkjeholt/development.git

chmod 755 development/bin/*

ln -s development/bin bin

cp development/.build_counter . 

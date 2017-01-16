#!/bin/bash -f

rm -r development
rm -r bin

git clone git://github.com/bkjeholt/development.git

ln -s development/bin bin

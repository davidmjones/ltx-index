# latex-index
index – Extended index support for LaTeX including multiple indexes

## How to install this file:

Run tex on index.ins to unpack the files index.sty and sample.tex.
Then install index.sty wherever style files belong on your system and
read the comments at the beginning of sample.tex to see how to run the
test.  Finally, format the documentation by executing the following
three commands:

   latex index.dtx
   makeindex -s gind.ist index
   latex index.dtx
   
Or if you're feeling brave, you can try to running build.sh to create
a TDS-compliant (I think) tree in the build directory.

David M. Jones
dmjones@alum.mit.edu
https://github.com/davidmjones/ltx-index/

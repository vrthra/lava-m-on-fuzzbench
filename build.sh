#!/bin/bash -ex
# for @@
apt-get -y install texinfo vim remake elinks
export FUZZ_TARGET=@@
xzcat $SRC/lava_corpus.tar.xz | (cd $SRC; tar -xpf -)
cd $SRC/lava_corpus/LAVA-M/$FUZZ_TARGET/coreutils-8.24-lava-safe
cat $SRC/lava_coreutils_patch.patch | patch -p1
cp src/make-prime-list.c src/make-prime-list.c_
perl -pi -e 's# exit *\(# exit_x(#g' src/*.h
perl -pi -e 's# exit *\(# exit_x(#g' src/*.c
perl -pi -e 's# exit *\(# exit_x(#g' lib/*.h
perl -pi -e 's# exit *\(# exit_x(#g' lib/*.c

perl -pi -e 's# _exit *\(# _exit_x(#g' src/*.h
perl -pi -e 's# _exit *\(# _exit_x(#g' src/*.c
perl -pi -e 's# _exit *\(# _exit_x(#g' lib/*.h
perl -pi -e 's# _exit *\(# _exit_x(#g' lib/*.c



perl -pi -e 's# abort *\(# abort_x(#g' src/*.h
perl -pi -e 's# abort *\(# abort_x(#g' src/*.c
perl -pi -e 's# abort *\(# abort_x(#g' lib/*.h
perl -pi -e 's# abort *\(# abort_x(#g' lib/*.c
mv src/make-prime-list.c_ src/make-prime-list.c

echo "void abort_x (); "              >> lib/config.h
echo "void exit_x (int status); "     >> lib/config.h
echo "void _exit_x (int status); "    >> lib/config.h

echo "void abort_x (); "              >> src/system.h
echo "void exit_x (int status); "     >> src/system.h
echo "void _exit_x (int status); "    >> src/system.h



echo FUZZERLIB=$FUZZER_LIB
FORCE_UNSAFE_CONFIGURE=1 LIBS=$FUZZER_LIB ./configure
cp src/$FUZZ_TARGET.c src/$FUZZ_TARGET.c._
cp src/version.c src/version.c._
echo "#include<stdlib.h>"                         >> src/version.c
echo "void abort_x (){abort();} "                 >> src/version.c
echo "void exit_x (int status) {exit(status);} "  >> src/version.c
echo "void _exit_x (int status) {exit(status);} " >> src/version.c
make

rm -f src/$FUZZ_TARGET 
cp src/version.c._ src/version.c
cat src/$FUZZ_TARGET.c._                           > src/$FUZZ_TARGET.c
perl -pi -e 's#^main #main_x #g'                     src/$FUZZ_TARGET.c
cat  $SRC/fuzz_utils.c $SRC/fuzzerentry.c         >> src/$FUZZ_TARGET.c
echo "#include<stdlib.h>"                         >> src/$FUZZ_TARGET.c
echo "void abort_x (){} "                         >> src/$FUZZ_TARGET.c
echo "void exit_x (int status) {} "               >> src/$FUZZ_TARGET.c
echo "void _exit_x (int status) {} "              >> src/$FUZZ_TARGET.c

rm -f src/version.o
make src/version.o
make  src/$FUZZ_TARGET.o
$CXX $CXXFLAGS -o src/$FUZZ_TARGET src/$FUZZ_TARGET.o src/version.o lib/libcoreutils.a  lib/libcoreutils.a $FUZZER_LIB


cp src/$FUZZ_TARGET $OUT/$FUZZ_TARGET

mkdir -p $OUT/seeds
echo "abcd\nefg" > $OUT/seeds/seed.txt

#!/bin/bash

set -e

BUILD_DOCS=0
BUILD_ZIP=0

for option in "$@"; do
    case $option in
        -all    ) BUILD_DOCS=1; BUILD_ZIP=1 ;;
        -doc    ) BUILD_DOCS=1 ;;
        -no-doc ) BUILD_DOCS=0 ;;
        -zip    ) BUILD_ZIP=1;  BUILD_DOCS=1 ;;
        -no-zip ) BUILD_ZIP=0 ;;
        *       ) echo "Invalid option: $option"; exit 1 ;;
    esac
done

if (($BUILD_ZIP)); then
    if ((! $BUILD_DOCS)); then
        echo "Forcing build of documentation for zip file"
        BUILD_DOCS=1
    fi
else
    echo "Not building ZIP files"
fi

if ((! $BUILD_DOCS)); then
    echo "Not building documentation"
fi

PACKAGES="index"

DOC_TXT="README.md sample/sample.tex"

BUILD=$PWD/build

TEXMF=$BUILD/texmf

SET_NAME=index

TEXMF_DOC=$TEXMF/doc/latex/$SET_NAME
TEXMF_SRC=$TEXMF/source/latex/$SET_NAME
TEXMF_CLS=$TEXMF/tex/latex/$SET_NAME

export openout_any=a
export TEXINPUTS="$TEXMF/tex//:"

if [ -e $BUILD ]; then
    rm -rf $BUILD
fi

# Create build directory structure

mkdir -p $TEXMF_SRC $TEXMF_CLS

if (($BUILD_DOCS)); then
    mkdir -p $TEXMF_DOC
fi

# Install documentation source in distrib source directory.

if (($BUILD_DOCS)); then
    for doc in $DOC_TXT
    do
        cp -p $doc $TEXMF_DOC
    done
fi

# Create init file for testing

cat > $BUILD/$SET_NAME-ini.sh <<EOF
tex_$SET_NAME=$TEXMF_CLS//

echo Setting '\$tex_$SET_NAME' to \$tex_$SET_NAME

echo 'Adding \$tex_$SET_NAME to TEXINPUTS for tex and latex'

if [ -z "$TEXINPUTS" ]; then
    TEXINPUTS=.:\${tex_$SET_NAME}:\${TEXINPUTS}:
else
    TEXINPUTS=.:\${tex_$SET_NAME}:
fi

export TEXINPUTS

echo "For prdlatex, type"
echo '    prdlatex -inputs \$tex_$SET_NAME ...'
EOF

# Install dtx and ins files in distrib source directory.

for pkg in $PACKAGES
do
    cp -p $pkg.dtx $pkg.ins $TEXMF_SRC
done

# Install documentation source in distrib source directory.

# Install example files in distrib source directory.

cat > $TEXMF_SRC/docstrip.cfg <<EOF
\BaseDirectory{$TEXMF}

\UseTDS

\endinput
EOF

cd $TEXMF_SRC

for pkg in $PACKAGES
do
    tex $pkg.ins && rm $pkg.log

    if (($BUILD_DOCS)); then
        pdflatex $pkg.dtx
        pdflatex $pkg.dtx

        if [ -e $pkg.idx ]; then
            makeindex -s gind $pkg
        fi

        pdflatex $pkg.dtx

        mv $pkg.pdf $TEXMF_DOC

        rm $pkg.{aux,idx,ilg,ind,log,toc,out,hd} || true
    fi
done

rm docstrip.cfg

cd ..

if (($BUILD_ZIP)); then 
    cd $BUILD

    mkdir zip_staging

    cd zip_staging

    cp -pr $TEXMF_SRC .

    for f in $TEXMF_DOC/*; do 
        cp $f $SET_NAME
    done

    cd $SET_NAME

    ls -R * > manifest.txt

    cd ..

    zip -r ../$SET_NAME.zip $SET_NAME

    cd $BUILD

    md5sum $SET_NAME.zip > $SET_NAME.zip.md5

    rm -rf zip_staging
fi

exit 0

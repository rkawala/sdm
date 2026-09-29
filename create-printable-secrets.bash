#!/bin/bash
#
# The SDM key drive has 3 secrets files that need to be restorable from paper.
# This script creates those files

set -euo pipefail

function errexit() {
    echo -e "$1"
    exit 1
}

function usage() {
    errexit "Usage: $0 /path/to/key/file/drive /path/to/output/dir"
}

function newline() {
    echo >> $1
}

function make_printable() {
    local infile=$keydrive/$1
    local outfile=$outdir/$1.txt
    local tempfile=`mktemp /tmp/XXXXXX`

    echo Backup of: $1 > $outfile
    newline $outfile
    objcopy -I binary -O ihex $infile $tempfile
    tr -d '' < $tempfile | sponge $tempfile
    cat $tempfile >> $outfile
    newline $outfile
    echo `md5sum $infile` >> $outfile
    newline $outfile
    echo "Remember to put the carriage returns back in the hex file before decoding" >> $outfile
}

keydrive=$1
[ "$keydrive" == "" ] && usage

outdir=$2
[ "$outdir" == "" ] && usage

if [ `ls -al $keydrive/*.lek | wc -l` != 1 ]; then
    errexit "There should be exactly one LEK file on the keydrive"
fi

rm -fr $outdir
mkdir -p $outdir

make_printable restic-env.sh
make_printable citadel-s3-user_accessKeys.csv
make_printable `basename $keydrive/*.lek`

exit 0
